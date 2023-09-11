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
                         icon:(NSString *)icon
                         chevronIcon:(NSString *)chevronIcon
                  hasPointer:(BOOL)hasPointer
                   isSelected:(BOOL)isSelected
                   isVisualized:(BOOL)isVisualized
                        state:(NSString *)state
                      variant:(NSString *)variant
                         size:(NSString *)size {
  self = [super init];
  if (self) {
    _label = label;
    _icon = icon;
    _chevronIcon = chevronIcon;
    _hasPointer = hasPointer;
    _isSelected = isSelected;
    _isVisualized = isVisualized;
    _state = state;
    _variant = variant;
    _size = size;
  }
  return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@",
            self.label,
            self.icon,
            self.chevronIcon,
            self.state,
            self.variant,
            self.size,
            self.hasPointer ? @"YES" : @"NO",
            self.isSelected ? @"YES" : @"NO",
            self.isVisualized ? @"YES" : @"NO"];
}
@end
