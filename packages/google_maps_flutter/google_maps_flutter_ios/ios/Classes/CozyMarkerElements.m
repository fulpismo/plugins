//
//  CozyMarkerElements.m
//  Pods
//
//  Created by Pietro Domingues on 26/09/23.
//

#import "CozyMarkerElements.h"

@implementation CozyMarkerElement
- (instancetype)initWithBounds:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor alpha:(CGFloat)alpha data:(NSObject *)data {
    self = [super init];
    if (self) {
        _bounds = bounds;
        _fillColor = fillColor;
        _strokeColor = strokeColor;
        _alpha = alpha;
        _data = data;
    }
    return self;
}
@end

@implementation CozyMarkerElements
- (instancetype)initWithCanvas:(CozyMarkerElement *)canvas bubble:(CozyMarkerElement *)bubble shadowBubble:(CozyMarkerElement *)shadowBubble labels:(NSArray<CozyMarkerElement *> *)labels counter:(CozyMarkerElement *)counter icon:(CozyMarkerElement *)icon iconCircle:(CozyMarkerElement *)iconCircle pointer:(CozyMarkerElement *)pointer {
    self = [super init];
    if (self) {
        _canvas = canvas;
        _bubble = bubble;
        _shadowBubble = shadowBubble;
        _counter = counter;
        _icon = icon;
        _iconCircle = iconCircle;
        _pointer = pointer;
        _labels = labels;
    }
    return self;
}
@end
