//
//  CozyMarkerData.m
//  google_maps_flutter_ios
//
//  Created by Pietro Domingues on 24/08/23.
//

#import <Foundation/Foundation.h>
#import "CozyMarkerData.h"

@implementation CozyMarkerData
- (instancetype)initWithLabel:(NSString *)label
                      counter:(NSString *)counter
                         icon:(NSString *)icon
                   hasPointer:(BOOL)hasPointer
                 hasElevation:(BOOL)hasElevation
                   isSelected:(BOOL)isSelected
                 isVisualized:(BOOL)isVisualized
                        state:(NSString *)state
                      variant:(NSString *)variant
                         size:(NSString *)size
                   isAnimated:(BOOL)isAnimated
{
    self = [super init];
    if (self) {
        _label = label;
        _counter = counter;
        _icon = icon;
        _hasPointer = hasPointer;
        _hasElevation = hasElevation;
        _isSelected = isSelected;
        _isVisualized = isVisualized;
        _state = state;
        _variant = variant;
        _size = size;
        _isAnimated = isAnimated;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %lu %@ %@ %@ %@ %@ %@ %@",
            self.label,
            self.counter,
            (unsigned long)[self.icon hash],
            self.state,
            self.variant,
            self.size,
            self.hasPointer ? @"YES" : @"NO",
            self.hasElevation ? @"YES" : @"NO",
            self.isSelected ? @"YES" : @"NO",
            self.isVisualized ? @"YES" : @"NO",
            self.isAnimated ? @"YES" : @"NO"
    ];
}

- (BOOL)isEqual:(CozyMarkerData *)other {
    return [[self description] isEqualToString:[other description]];
}
@end
