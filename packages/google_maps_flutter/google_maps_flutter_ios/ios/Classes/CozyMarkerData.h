//
//  CozyMarkerData.h
//  Pods
//
//  Created by Pietro Domingues on 24/08/23.
//

@interface CozyMarkerData : NSObject
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
                   isAnimated:(BOOL)isAnimated;

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *counter;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *variant;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, assign) BOOL hasPointer;
@property (nonatomic, assign) BOOL hasElevation;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isVisualized;
@property (nonatomic, assign) BOOL isAnimated;
@end
