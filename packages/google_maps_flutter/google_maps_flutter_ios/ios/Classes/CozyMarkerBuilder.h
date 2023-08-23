//
//  CozyMarkerBuilder.h
//  google_maps_flutter_ios-CozyFonts
//
//  Created by Luiz Carvalho on 16/02/23.
//
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CozyMarkerBuilder : NSObject
- (instancetype) initWithCache:(BOOL)useCache;
- (UIImage *) buildMarker:(NSString *)label withMarkerType:(NSString *)markerType withAlpha:(CGFloat)alpha;

@property(strong, nonatomic) NSCache *cache;
@property(strong, nonatomic) NSString *fontPath;
@property(nonatomic, assign) CGFloat markerSize;
@property(nonatomic, assign) CGFloat shadowWidth;
@property(nonatomic, assign) BOOL useCache;
@end

