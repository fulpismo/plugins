//
//  CozyMarkerElementsBuilder.m
//  Pods
//
//  Created by Pietro Domingues on 26/09/23.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CozyMarkerElementsBuilder.h"
#import "CozyMarkerData.h"
#import "CozyMarkerElements.h"

@implementation CozyMarkerElementsBuilder


- (instancetype)initWithFontPath:(NSString *)fontPath strokeSize:(CGFloat)strokeSize {
    self = [super init];
    if (self) {
        _fontPath = fontPath;
        _strokeSize = strokeSize;
    }
    return self;
}

- (BOOL)isMiniMarker:(NSString *)size {
    return [size isEqualToString:@"mini"] || [size isEqualToString:@"miniDot"];
}

- (CozyMarkerElements *)cozyElementsFromData:(CozyMarkerData *)cozyMarkerData {
    NSString *text = cozyMarkerData.label;
    NSString *icon = cozyMarkerData.icon;
    NSString *counterText = cozyMarkerData.counter;
    BOOL hasPointer = cozyMarkerData.hasPointer;
    BOOL hasElevation = cozyMarkerData.hasElevation;

    if ([self isMiniMarker:cozyMarkerData.size]) {
        text = @"";
        counterText = NULL;
        icon = NULL;
        hasPointer = NO;
    } 
    /* setting colors */
    UIColor *const defaultMarkerColor = UIColor.whiteColor;
    UIColor *const defaultTextColor = UIColor.blackColor;
    UIColor *const defaultStrokeColor = [UIColor colorWithRed:
                                         215.0f / 255.0f
                                                        green:(215.0f /
                                                               255.0f) blue:(
                                                                             221.0f /
                                                                             255.0f)                             alpha:1];
    
    UIColor *const defaultIconCircleColor = [UIColor colorWithRed:(
                                                                   248.0f / 255.0f)
                                                            green:(249.f /
                                                                   255.0f) blue:(
                                                                                 245.0f /
                                                                                 255.0f)                                 alpha:1];

    UIColor *const defaultCounterBubbleColor = [UIColor colorWithRed:(
                                                               235.0f / 255.0f)
                                                        green:(237.f /
                                                               255.0f) blue:(
                                                                             230.0f /
                                                                             255.0f)                             alpha:1];
    
    UIColor *const defaultIconColor = UIColor.blackColor;
    
    UIColor *const selectedMarkerColor = [UIColor colorWithRed:(57.0f / 255.0f) green:(87.0f /
                                                                                       255.0f) blue:(
                                                                                                     189.0f / 255.0f) alpha:1];
    UIColor *const selectedTextColor = UIColor.whiteColor;
    UIColor *const selectedIconCircleColor = UIColor.whiteColor;
    UIColor *const selectedCounterBubbleColor = [UIColor colorWithRed:(
                    248.0f / 255.0f)
                                                            green:(249.f /
                                                                   255.0f) blue:(
                    245.0f /
                    255.0f)                                 alpha:1];
    
    UIColor *const visualizedMarkerColor = [UIColor colorWithRed:(215.0f / 255.0f) green:(215.0f /
                                                                                          255.0f) blue:(
                                                                                                        221.0f / 255.0f) alpha:1];
    UIColor *const visualizedTextColor = UIColor.blackColor;
    UIColor *const visualizedStrokeColor = [UIColor colorWithRed:(215.0f / 255.0f) green:(215.0f / 255.0f) blue:(221.0f / 255.0f) alpha:1];
    UIColor *const visualizedIconCircleColor = UIColor.whiteColor;
    UIColor *const visualizedCounterBubbleColor = [UIColor colorWithRed:(
                    248.0f / 255.0f)
                                                                green:(249.f /
                                                                       255.0f) blue:(
                    245.0f /
                    255.0f)                                 alpha:1];
    
    UIColor *const specialIconCircleColor = [UIColor colorWithRed:(240.0f / 255.0f) green:(243.0f /
                                                                                           255.0f) blue:(
                                                                                                         255.0f / 255.0f) alpha:1];
    UIColor *const specialIconColor = [UIColor colorWithRed:(57.0f / 255.0f) green:(87.0f /
                                                                                    255.0f) blue:(
                                                                                                  189.0f / 255.0f) alpha:1];
    
    UIColor *markerColor = defaultMarkerColor;
    UIColor *textColor = defaultTextColor;
    UIColor *iconCircleColor = defaultIconCircleColor;
    UIColor *iconColor = defaultIconColor;
    UIColor *strokeColor = defaultStrokeColor;
    UIColor *counterBubbleColor = defaultCounterBubbleColor;
    
    if (cozyMarkerData.isVisualized) {
        markerColor = visualizedMarkerColor;
        textColor = visualizedTextColor;
        strokeColor = visualizedStrokeColor;
        iconCircleColor = visualizedIconCircleColor;
        counterBubbleColor = visualizedCounterBubbleColor;
    }
    if (cozyMarkerData.isSelected) {
        markerColor = selectedMarkerColor;
        textColor = selectedTextColor;
        strokeColor = defaultStrokeColor;
        iconCircleColor = selectedIconCircleColor;
        counterBubbleColor = selectedCounterBubbleColor;
    }
    if ([cozyMarkerData.variant isEqualToString:@"special"] &&
        (!cozyMarkerData.isVisualized || cozyMarkerData.isSelected)) {
        iconCircleColor = specialIconCircleColor;
        iconColor = specialIconColor;
    }
    if ([self isMiniMarker:cozyMarkerData.size]) {
        strokeColor = [UIColor colorWithRed:
                                         175.0f / 255.0f
                                                        green:(179.0f /
                                                               255.0f) blue:(
                                                                             165.0f /
                                                                             255.0f)                             alpha:1];
    }
    
    /* setting constants */
    // setting padding and stroke size
    const CGFloat paddingVertical = 10.5f;
    const CGFloat paddingHorizontal = 11;
    const CGFloat minMarkerWidth = 40;
    
    // setting constants for pointer
    const CGFloat pointerWidth = 6;
    const CGFloat pointerHeight = 5;
    
    // setting constants for icon
    const CGFloat iconSize = 16;
    const CGFloat iconCircleSize = 24;
    const CGFloat iconLeftPadding = 5;
    const CGFloat iconRightPadding = 3;
    const CGFloat elevation = hasElevation ? 4 : 0;
    const CGFloat totalStrokeSize = self.strokeSize + elevation;
    const CGFloat miniPinRadius = 4;
    const CGFloat miniPinWidth = 14;
    
    // setting constants for coutner
    const CGFloat counterBubblePadding = 6;
    
    /* setting variables */
    // getting font and setting its size to 3 the size of the marker size
    const CGFloat fontSize = 12;
    UIFont *textFont = [UIFont fontWithName:self.fontPath size:fontSize];
    CGSize stringSize = [text sizeWithAttributes:@{NSFontAttributeName: textFont}];
    CGSize counterTextSize = [counterText sizeWithAttributes:@{NSFontAttributeName: textFont}];
    
    // additionalIconWidth to be used on markerWidth
    CGFloat iconAdditionalWidth = icon != NULL ? iconCircleSize + iconRightPadding : 0;
    
    // set the marker height as the string height with space for padding and stroke
    CGFloat markerHeight = stringSize.height + (2 * paddingVertical) + 2 * self.strokeSize;
    
    // bubbles shape properties
    CGFloat bubbleShapeHeight = markerHeight - self.strokeSize * 2;
    CGFloat counterBubbleShapeHeight = bubbleShapeHeight - (counterBubblePadding * 2);
    
    // counter summary width
    CGFloat counterSummaryWidth = counterText ? MAX(counterTextSize.width + counterBubblePadding * 2,
                                                    counterBubbleShapeHeight) : 0;
    
    // pointerSize to be used on bitmap creation
    CGFloat pointerSize = hasPointer ? pointerHeight : 0;
    
    // setting marker width with a minimum width in case the string size is below the minimum
    CGFloat markerWidth = stringSize.width + (2 * paddingHorizontal) + (2 * self.strokeSize) +
    iconAdditionalWidth + counterSummaryWidth;
    if (markerWidth < minMarkerWidth) {
        markerWidth = minMarkerWidth;
    }

    if([self isMiniMarker:cozyMarkerData.size]) {
        if([cozyMarkerData.size isEqualToString:@"mini"]) {
            markerHeight = (miniPinRadius * 2) + (2 * self.strokeSize);
            markerWidth = miniPinWidth + (2 * self.strokeSize);
        }
        if([cozyMarkerData.size isEqualToString:@"miniDot"]) {
            markerHeight = (miniPinRadius * 2) + (2 * self.strokeSize);
            markerWidth = (miniPinRadius * 2) + (2 * self.strokeSize);
        }
        bubbleShapeHeight = markerHeight - (self.strokeSize * 2);
    }

    CGFloat canvasWidth = markerWidth + (2 * elevation);
    CGFloat canvasHeight = markerHeight + (2 * elevation) + pointerSize;
    
    // bubble coordinates
    CGFloat bubbleShapeX = totalStrokeSize;
    CGFloat bubbleShapeY = totalStrokeSize;
    CGFloat bubbleShapeWidth = markerWidth - self.strokeSize * 2;
    
    // counter bubble coordinates
    CGFloat counterBubbleShapeX =
    canvasWidth - counterSummaryWidth - counterBubblePadding - totalStrokeSize;
    CGFloat counterBubbleShapeY = counterBubblePadding + totalStrokeSize;
    
    // generic position variables
    CGFloat middleOfMarkerY = (bubbleShapeHeight / 2) + totalStrokeSize;
    
    // counter text coordinates
    CGFloat counterTextX =
    counterBubbleShapeX + (counterSummaryWidth / 2) - (counterTextSize.width / 2);
    CGFloat counterTextY = middleOfMarkerY - (counterTextSize.height / 2);
    
    // text coordinates
    CGFloat textY = middleOfMarkerY - (stringSize.height / 2);
    CGFloat textX = (canvasWidth / 2) - (stringSize.width / 2) + iconAdditionalWidth / 2 - counterSummaryWidth / 2;
    CGFloat textWidth = stringSize.width;
    CGFloat textHeight = stringSize.height;
    
    // icon coordinates
    CGFloat iconX = totalStrokeSize + iconLeftPadding + (iconCircleSize - iconSize) / 2;
    CGFloat iconY = middleOfMarkerY - iconSize / 2;
    CGFloat iconWidth = iconSize;
    CGFloat iconHeight = iconSize;
    
    // icon circle coordinates
    CGFloat iconCircleX = totalStrokeSize + iconLeftPadding;
    CGFloat iconCircleY = middleOfMarkerY - iconCircleSize / 2;
    CGFloat iconCircleWidth = iconCircleSize;
    CGFloat iconCircleHeight = iconCircleSize;
    
    // pointer coordinates
    CGFloat pointerX = canvasWidth / 2 - pointerWidth;
    CGFloat pointerY = canvasHeight - pointerSize - totalStrokeSize;

    CGFloat shadowAlpha = hasElevation ? [self isMiniMarker:cozyMarkerData.size] ? 0.15 : 0.08 : 0;
    
    return [[CozyMarkerElements alloc] initWithCanvas:[[CozyMarkerElement alloc]
                                                       initWithBounds:CGRectMake(0, 0, canvasWidth, canvasHeight)
                                                       fillColor:markerColor
                                                       strokeColor:strokeColor
                                                       alpha:1
                                                       data:nil]
                                               bubble:[[CozyMarkerElement alloc]
                                                       initWithBounds:CGRectMake(bubbleShapeX,
                                                                                 bubbleShapeY,
                                                                                 bubbleShapeWidth,
                                                                                 bubbleShapeHeight)
                                                       fillColor:markerColor
                                                       strokeColor:strokeColor
                                                       alpha:1
                                                       data:nil]
                                                shadowBubble: [[CozyMarkerElement alloc]
                                                               initWithBounds:CGRectMake(bubbleShapeX,
                                                                                         bubbleShapeY + 2,
                                                                                         bubbleShapeWidth,
                                                                                         bubbleShapeHeight)
                                                               fillColor:UIColor.blackColor
                                                               strokeColor:nil
                                                               alpha: shadowAlpha
                                                               data:nil]
                                               labels:@[[[CozyMarkerElement alloc]
                                                         initWithBounds:CGRectMake(textX,
                                                        textY,
                                                        textWidth,
                                                        textHeight)
                                                         fillColor:textColor
                                                         strokeColor:nil
                                                         alpha:1
                                                         data:text],
                                                        [[CozyMarkerElement alloc]
                                                         initWithBounds:CGRectMake(
                                                        counterTextX,
                                                        counterTextY,
                                                        counterTextSize.width,
                                                        counterTextSize.height)
                                                         fillColor:defaultTextColor
                                                         strokeColor:nil
                                                         alpha:1
                                                         data:counterText]]
                                              counter:[[CozyMarkerElement alloc]
                                                       initWithBounds:CGRectMake(counterBubbleShapeX,
                                                                                 counterBubbleShapeY,
                                                                                 counterSummaryWidth,
                                                                                 counterBubbleShapeHeight)
                                                       fillColor:counterBubbleColor
                                                       strokeColor:strokeColor
                                                       alpha:1
                                                       data:counterText]
                                                 icon:[[CozyMarkerElement alloc]
                                                       initWithBounds:CGRectMake(iconX, iconY,
                                                                                 iconWidth,
                                                                                 iconHeight)
                                                       fillColor:iconColor
                                                       strokeColor:nil
                                                       alpha:icon == NULL ? 0 : 1
                                                       data:icon]
                                           iconCircle:[[CozyMarkerElement alloc]
                                                       initWithBounds:CGRectMake(iconCircleX,
                                                                                 iconCircleY,
                                                                                 iconCircleWidth,
                                                                                 iconCircleHeight)
                                                       fillColor:iconCircleColor
                                                       strokeColor:nil
                                                       alpha:icon == NULL ? 0 : 1
                                                       data:nil]
                                              pointer:[[CozyMarkerElement alloc]
                                                       initWithBounds:CGRectMake(pointerX, pointerY,
                                                                                 2 * pointerWidth,
                                                                                 pointerSize)
                                                       fillColor:markerColor
                                                       strokeColor:markerColor
                                                       alpha:1
                                                       data:nil]];
    
}

@end
