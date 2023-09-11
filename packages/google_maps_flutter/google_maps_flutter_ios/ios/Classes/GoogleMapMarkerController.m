// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"
#import "FLTGoogleMapJSONConversions.h"
#import "UIKit/UIGraphics.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

@interface FLTGoogleMapMarkerController ()

@property(strong, nonatomic) GMSMarker *marker;
@property(weak, nonatomic) GMSMapView *mapView;
@property(assign, nonatomic, readwrite) BOOL consumeTapEvents;
@property(nonatomic, assign) BOOL markersAnimationEnabled;
@property(nonatomic, assign) int markersAnimationDuration;
@property(strong, nonatomic) CozyMarkerBuilder *cozy;

@end

@implementation FLTGoogleMapMarkerController

- (instancetype)initMarkerWithPosition:(CLLocationCoordinate2D)position
                            identifier:(NSString *)identifier
                               mapView:(GMSMapView *)mapView
                            cozyMarkerBuilder:(nonnull CozyMarkerBuilder *)cozy
                            markersAnimationEnabled:(BOOL)markersAnimationEnabled {
    self = [super init];
    if (self) { 
        _cozy = cozy;
        _marker = [GMSMarker markerWithPosition:position];
        _mapView = mapView;
        _marker.userData = @[ identifier ];
        _markersAnimationEnabled = markersAnimationEnabled;
        _markersAnimationDuration = 100;
    }
    if(markersAnimationEnabled){
        float durationInMillis = _markersAnimationDuration;
        float durationInSeconds = durationInMillis/1000;

        CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeIn.fromValue = [NSNumber numberWithFloat:0.0];
        fadeIn.toValue = [NSNumber numberWithFloat:1.0];
        fadeIn.duration = durationInSeconds;
        fadeIn.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5: 1: 0.89: 1];

        [_marker.layer addAnimation:fadeIn forKey:@"fadeInAnimation"];
    }
    return self;
}

- (void)showInfoWindow {
    self.mapView.selectedMarker = self.marker;
}

- (void)hideInfoWindow {
    if (self.mapView.selectedMarker == self.marker) {
        self.mapView.selectedMarker = nil;
    }
}

- (BOOL)isInfoWindowShown {
    return self.mapView.selectedMarker == self.marker;
}

- (void)removeMarker {
    if(self.markersAnimationEnabled){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.markersAnimationDuration * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [CATransaction begin];
            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeOut.fromValue = [NSNumber numberWithFloat:1.0];
            fadeOut.toValue = [NSNumber numberWithFloat:0.0];

            float durationInMillis = self.markersAnimationDuration;
            fadeOut.duration = durationInMillis/1000;
            fadeOut.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.11: 0: 0.5: 0];
            
            fadeOut.fillMode = kCAFillModeForwards;
            fadeOut.removedOnCompletion = NO;

            [CATransaction setCompletionBlock:^{
                self.marker.map = nil;
            }];

            [self.marker.layer addAnimation:fadeOut forKey:@"fadeOutAnimation"];
            [CATransaction commit];
        });
    }else{
        self.marker.map = nil;
    }
}

- (void)setAlpha:(float)alpha {
    self.marker.opacity = alpha;
}

- (void)setAnchor:(CGPoint)anchor {
    self.marker.groundAnchor = anchor;
}

- (void)setDraggable:(BOOL)draggable {
    self.marker.draggable = draggable;
}

- (void)setFlat:(BOOL)flat {
    self.marker.flat = flat;
}

- (void)setIcon:(UIImage *)icon {
    self.marker.icon = icon;
}

- (void)setInfoWindowAnchor:(CGPoint)anchor {
    self.marker.infoWindowAnchor = anchor;
}

- (void)setInfoWindowTitle:(NSString *)title snippet:(NSString *)snippet {
    self.marker.title = title;
    self.marker.snippet = snippet;
}

- (void)setPosition:(CLLocationCoordinate2D)position {
    self.marker.position = position;
}

- (void)setRotation:(CLLocationDegrees)rotation {
    self.marker.rotation = rotation;
}

- (void)setVisible:(BOOL)visible {
    self.marker.map = visible ? self.mapView : nil;
}

- (void)setZIndex:(int)zIndex {
    self.marker.zIndex = zIndex;
}


- (void)interpretMarkerOptions:(NSDictionary *)data
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    NSNumber *alpha = data[@"alpha"];
    if (alpha && alpha != (id)[NSNull null]) {
        [self setAlpha:[alpha floatValue]];
    }
    NSArray *anchor = data[@"anchor"];
    if (anchor && anchor != (id)[NSNull null]) {
        [self setAnchor:[FLTGoogleMapJSONConversions pointFromArray:anchor]];
    }
    NSNumber *draggable = data[@"draggable"];
    if (draggable && draggable != (id)[NSNull null]) {
        [self setDraggable:[draggable boolValue]];
    }

    NSDictionary *cozyMarkerDataDict = data[@"cozyMarkerData"];
    if (cozyMarkerDataDict && cozyMarkerDataDict != (id)[NSNull null]) {
        [self interpretCozyMarkerData:cozyMarkerDataDict];
    }else{
        NSArray *icon = data[@"icon"];
        if (icon && icon != (id)[NSNull null]) {
            UIImage *image = [self extractIconFromData:icon registrar:registrar];
            [self setIcon:image];
        }
    }

    NSNumber *flat = data[@"flat"];
    if (flat && flat != (id)[NSNull null]) {
        [self setFlat:[flat boolValue]];
    }
    NSNumber *consumeTapEvents = data[@"consumeTapEvents"];
    if (consumeTapEvents && consumeTapEvents != (id)[NSNull null]) {
        [self setConsumeTapEvents:[consumeTapEvents boolValue]];
    }

    [self interpretInfoWindow:data];

    NSArray *position = data[@"position"];
    if (position && position != (id)[NSNull null]) {
        [self setPosition:[FLTGoogleMapJSONConversions locationFromLatLong:position]];
    }
    NSNumber *rotation = data[@"rotation"];
    if (rotation && rotation != (id)[NSNull null]) {
        [self setRotation:[rotation doubleValue]];
    }
    NSNumber *visible = data[@"visible"];
    if (visible && visible != (id)[NSNull null]) {
        [self setVisible:[visible boolValue]];
    }
    NSNumber *zIndex = data[@"zIndex"];
    if (zIndex && zIndex != (id)[NSNull null]) {
        [self setZIndex:[zIndex intValue]];
    }
}

- (void)interpretInfoWindow:(NSDictionary *)data {
    NSDictionary *infoWindow = data[@"infoWindow"];
    if (infoWindow && infoWindow != (id)[NSNull null]) {
        NSString *title = infoWindow[@"title"];
        NSString *snippet = infoWindow[@"snippet"];
        if (title && title != (id)[NSNull null]) {
            [self setInfoWindowTitle:title snippet:snippet];
        }
        NSArray *infoWindowAnchor = infoWindow[@"infoWindowAnchor"];
        if (infoWindowAnchor && infoWindowAnchor != (id)[NSNull null]) {
            [self setInfoWindowAnchor:[FLTGoogleMapJSONConversions pointFromArray:infoWindowAnchor]];
        }
    }
}

- (void)interpretCozyMarkerData:(NSDictionary *)cozyMarkerDataDict {
    CozyMarkerData *cozyMarkerData = [[CozyMarkerData alloc] initWithLabel:cozyMarkerDataDict[@"label"] 
                                                                icon:cozyMarkerDataDict[@"icon"]
                                                                chevronIcon:cozyMarkerDataDict[@"chevronIcon"]
                                                                hasPointer: [cozyMarkerDataDict[@"hasPointer"] boolValue]
                                                                isSelected: [cozyMarkerDataDict[@"isSelected"] boolValue]
                                                                isVisualized: [cozyMarkerDataDict[@"isVisualized"] boolValue]
                                                                state: cozyMarkerDataDict[@"state"]
                                                                variant: cozyMarkerDataDict[@"variant"]
                                                                size: cozyMarkerDataDict[@"size"]];

    UIImage *image = [[self cozy] buildMarkerWithData:cozyMarkerData];
    [self setIcon:image];
}

- (UIImage *)extractIconFromData:(NSArray *)iconData
                       registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    UIImage *image;
    if ([iconData.firstObject isEqualToString:@"defaultMarker"]) {
        CGFloat hue = (iconData.count == 1) ? 0.0f : [iconData[1] doubleValue];
        image = [GMSMarker markerImageWithColor:[UIColor colorWithHue:hue / 360.0
                                                           saturation:1.0
                                                           brightness:0.7
                                                                alpha:1.0]];
    } else if ([iconData.firstObject isEqualToString:@"fromAsset"]) {
        if (iconData.count == 2) {
            image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
        } else {
            image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]
                                                         fromPackage:iconData[2]]];
        }
    } else if ([iconData.firstObject isEqualToString:@"fromAssetImage"]) {
        if (iconData.count == 3) {
            image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
            id scaleParam = iconData[2];
            image = [self scaleImage:image by:scaleParam];
        } else {
            NSString *error =
            [NSString stringWithFormat:@"'fromAssetImage' should have exactly 3 arguments. Got: %lu",
             (unsigned long)iconData.count];
            NSException *exception = [NSException exceptionWithName:@"InvalidBitmapDescriptor"
                                                             reason:error
                                                           userInfo:nil];
            @throw exception;
        }
    } else if ([iconData[0] isEqualToString:@"fromBytes"]) {
        if (iconData.count == 2) {
            @try {
                FlutterStandardTypedData *byteData = iconData[1];
                CGFloat screenScale = [[UIScreen mainScreen] scale];
                image = [UIImage imageWithData:[byteData data] scale:screenScale];
            } @catch (NSException *exception) {
                @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                               reason:@"Unable to interpret bytes as a valid image."
                                             userInfo:nil];
            }
        } else {
            NSString *error = [NSString
                               stringWithFormat:@"fromBytes should have exactly one argument, the bytes. Got: %lu",
                               (unsigned long)iconData.count];
            NSException *exception = [NSException exceptionWithName:@"InvalidByteDescriptor"
                                                             reason:error
                                                           userInfo:nil];
            @throw exception;
        }
    }
    
    return image;
}

- (UIImage *)scaleImage:(UIImage *)image by:(id)scaleParam {
    double scale = 1.0;
    if ([scaleParam isKindOfClass:[NSNumber class]]) {
        scale = [scaleParam doubleValue];
    }
    if (fabs(scale - 1) > 1e-3) {
        return [UIImage imageWithCGImage:[image CGImage]
                                   scale:(image.scale * scale)
                             orientation:(image.imageOrientation)];
    }
    return image;
}

@end

@interface FLTMarkersController ()

@property(strong, nonatomic) NSMutableDictionary *markerIdentifierToController;
@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) CozyMarkerBuilder *cozy;
@property(nonatomic, assign) BOOL markersAnimationEnabled;

@end

@implementation FLTMarkersController

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)methodChannel
                              mapView:(GMSMapView *)mapView
                            registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                            cozyMarkerBuilder:(nonnull CozyMarkerBuilder *)cozy
                            markersAnimationEnabled:(BOOL)markersAnimationEnabled {
    self = [super init];
    if (self) {
        _methodChannel = methodChannel;
        _mapView = mapView;
        _markerIdentifierToController = [[NSMutableDictionary alloc] init];
        _registrar = registrar;
        _cozy = cozy;
        _markersAnimationEnabled = markersAnimationEnabled;
    }
    return self;
}


- (void)addMarkers:(NSArray *)markersToAdd {
    for (NSDictionary *marker in markersToAdd) {
        CLLocationCoordinate2D position = [FLTMarkersController getPosition:marker];
        NSString *identifier = marker[@"markerId"];
        FLTGoogleMapMarkerController *controller =
        [[FLTGoogleMapMarkerController alloc] initMarkerWithPosition:position
                                                          identifier:identifier
                                                             mapView:self.mapView
                                                    cozyMarkerBuilder:self.cozy
                                                    markersAnimationEnabled: self.markersAnimationEnabled];
        [controller interpretMarkerOptions:marker registrar:self.registrar];
        self.markerIdentifierToController[identifier] = controller;
    }
}

- (void)changeMarkers:(NSArray *)markersToChange {
    for (NSDictionary *marker in markersToChange) {
        NSString *identifier = marker[@"markerId"];
        FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
        if (!controller) {
            continue;
        }
        [controller interpretMarkerOptions:marker registrar:self.registrar];
    }
}

- (void)removeMarkersWithIdentifiers:(NSArray *)identifiers {
    for (NSString *identifier in identifiers) {
        FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
        if (!controller) {
            continue;
        }
        [controller removeMarker];
        [self.markerIdentifierToController removeObjectForKey:identifier];
    }
}

- (BOOL)didTapMarkerWithIdentifier:(NSString *)identifier {
    if (!identifier) {
        return NO;
    }
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    if (!controller) {
        return NO;
    }
    [self.methodChannel invokeMethod:@"marker#onTap" arguments:@{@"markerId" : identifier}];
    return controller.consumeTapEvents;
}

- (void)didStartDraggingMarkerWithIdentifier:(NSString *)identifier
                                    location:(CLLocationCoordinate2D)location {
    if (!identifier) {
        return;
    }
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    if (!controller) {
        return;
    }
    [self.methodChannel invokeMethod:@"marker#onDragStart"
                           arguments:@{
        @"markerId" : identifier,
        @"position" : [FLTGoogleMapJSONConversions arrayFromLocation:location]
    }];
}

- (void)didDragMarkerWithIdentifier:(NSString *)identifier
                           location:(CLLocationCoordinate2D)location {
    if (!identifier) {
        return;
    }
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    if (!controller) {
        return;
    }
    [self.methodChannel invokeMethod:@"marker#onDrag"
                           arguments:@{
        @"markerId" : identifier,
        @"position" : [FLTGoogleMapJSONConversions arrayFromLocation:location]
    }];
}

- (void)didEndDraggingMarkerWithIdentifier:(NSString *)identifier
                                  location:(CLLocationCoordinate2D)location {
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    if (!controller) {
        return;
    }
    [self.methodChannel invokeMethod:@"marker#onDragEnd"
                           arguments:@{
        @"markerId" : identifier,
        @"position" : [FLTGoogleMapJSONConversions arrayFromLocation:location]
    }];
}

- (void)didTapInfoWindowOfMarkerWithIdentifier:(NSString *)identifier {
    if (identifier && self.markerIdentifierToController[identifier]) {
        [self.methodChannel invokeMethod:@"infoWindow#onTap" arguments:@{@"markerId" : identifier}];
    }
}

- (void)showMarkerInfoWindowWithIdentifier:(NSString *)identifier result:(FlutterResult)result {
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    if (controller) {
        [controller showInfoWindow];
        result(nil);
    } else {
        result([FlutterError errorWithCode:@"Invalid markerId"
                                   message:@"showInfoWindow called with invalid markerId"
                                   details:nil]);
    }
}

- (void)hideMarkerInfoWindowWithIdentifier:(NSString *)identifier result:(FlutterResult)result {
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    if (controller) {
        [controller hideInfoWindow];
        result(nil);
    } else {
        result([FlutterError errorWithCode:@"Invalid markerId"
                                   message:@"hideInfoWindow called with invalid markerId"
                                   details:nil]);
    }
}

- (void)isInfoWindowShownForMarkerWithIdentifier:(NSString *)identifier
                                          result:(FlutterResult)result {
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    if (controller) {
        result(@([controller isInfoWindowShown]));
    } else {
        result([FlutterError errorWithCode:@"Invalid markerId"
                                   message:@"isInfoWindowShown called with invalid markerId"
                                   details:nil]);
    }
}

- (void)setMarkersAnimationEnabled:(BOOL)enabled {
  _markersAnimationEnabled = enabled;
}

+ (CLLocationCoordinate2D)getPosition:(NSDictionary *)marker {
    NSArray *position = marker[@"position"];
    return [FLTGoogleMapJSONConversions locationFromLatLong:position];
}

@end
