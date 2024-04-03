//
//  CozyMarkerBuilder.h
//  google_maps_flutter_ios-CozyFonts
//
//  Created by Luiz Carvalho on 16/02/23.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CozyMarkerData.h"
#import "CozyMarkerElementsBuilder.h"
#import "CozyMarkerInterpolator.h"
#import "CozyMarkerElements.h"

@interface CozyMarkerBuilder : NSObject
- (UIImage *) buildMarkerWithData:(CozyMarkerData *)data;
- (UIImage *) buildInterpolatedMarkerWithData:(CozyMarkerElements *)startMarkerData endMarkerData:(CozyMarkerElements *)endMarkerData step:(CGFloat)step;

@property(strong, nonatomic) NSCache *cache;
@property(strong, nonatomic) NSString *fontPath;
@property(strong, nonatomic) CozyMarkerElementsBuilder *cozyMarkerElementsBuilder;
@property(strong, nonatomic) CozyMarkerInterpolator *cozyMarkerInterpolator;
@property(nonatomic, assign) CGFloat strokeSize;
@property(nonatomic, assign) CGFloat shadowBlurSize;
@property(nonatomic, assign) BOOL useCache;
@end

