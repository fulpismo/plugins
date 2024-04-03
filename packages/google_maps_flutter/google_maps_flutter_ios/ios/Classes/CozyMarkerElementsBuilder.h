//
//  CozyMarkerElementsBuilder.h
//  Pods
//
//  Created by Pietro Domingues on 26/09/23.
//

#import "CozyMarkerData.h"
#import "CozyMarkerElements.h"

@interface CozyMarkerElementsBuilder : NSObject
- (instancetype) initWithFontPath: (NSString *)fontPath strokeSize:(CGFloat)strokeSize;
- (BOOL)isMiniMarker:(NSString *)size;
- (CozyMarkerElements *)cozyElementsFromData:(CozyMarkerData *)data;

@property(strong, nonatomic) NSString *fontPath;
@property(assign, nonatomic) CGFloat strokeSize;
@end
