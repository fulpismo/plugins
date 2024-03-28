//
//  CozyMarkerElements.h
//  Pods
//
//  Created by Pietro Domingues on 26/09/23.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CozyMarkerElement : NSObject
@property CGRect bounds;
@property UIColor *fillColor;
@property UIColor *strokeColor;
@property CGFloat alpha;
@property NSObject *data;
- (instancetype)initWithBounds:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor alpha:(CGFloat)alpha data:(NSObject *)data;
@end

@interface CozyMarkerElements : NSObject
@property CozyMarkerElement *canvas;
@property CozyMarkerElement *bubble;
@property CozyMarkerElement *shadowBubble;
@property CozyMarkerElement *icon;
@property CozyMarkerElement *counter;
@property CozyMarkerElement *iconCircle;
@property CozyMarkerElement *pointer;
@property NSArray<CozyMarkerElement *> *labels;
- (instancetype)initWithCanvas:(CozyMarkerElement *)canvas bubble:(CozyMarkerElement *)bubble shadowBubble:(CozyMarkerElement *)shadowBubble labels:(NSArray<CozyMarkerElement *> *)labels counter:(CozyMarkerElement *)counter icon:(CozyMarkerElement *)icon iconCircle:(CozyMarkerElement *)iconCircle pointer:(CozyMarkerElement *)pointer;
@end
