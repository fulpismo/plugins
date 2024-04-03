//
//  CozyMarkerBuilder.m
//  google_maps_flutter_ios
//
//  Created by Luiz Carvalho on 16/02/23.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CozyMarkerBuilder.h"
#import "CozyMarkerElementsBuilder.h"
#import "CozyMarkerInterpolator.h"
#import "CozyMarkerElements.h"
#import "CozyMarkerData.h"
#import <SVGKit/SVGKit.h>

@implementation CozyMarkerBuilder


- (instancetype)init {
    self = [super init];
    if (self) {
        _fontPath = [self loadCozyFont];
        _cache = [[NSCache alloc] init];
        _strokeSize = 3;
        _shadowBlurSize = 4;
        
        _cozyMarkerInterpolator = [[CozyMarkerInterpolator alloc] init];
        _cozyMarkerElementsBuilder = [[CozyMarkerElementsBuilder alloc] initWithFontPath:_fontPath strokeSize:self.strokeSize];
    }
    return self;
}

- (NSString *)loadCozyFont {
    CGFontRef font = [self fontRefFromBundle];
    [self registerFont:font];
    NSString *fontName = (__bridge NSString *) CGFontCopyPostScriptName(font);
    CFSafeRelease(font);
    return fontName;
}

- (void)registerFont:(CGFontRef)font {
    CFErrorRef error;
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        
        CFRelease(errorDescription);
    }
}

- (CGFontRef)fontRefFromBundle {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.classForCoder];
    NSURL *bundleURL = [[frameworkBundle resourceURL] URLByAppendingPathComponent:@"CozyFonts.bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSURL *fontURL = [bundle URLForResource:@"oatmealpro2_semibold" withExtension:@"otf"];
    NSData *inData = [NSData dataWithContentsOfURL:fontURL];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef) inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    CFSafeRelease(provider);
    return font;
}

void CFSafeRelease(CFTypeRef cf) {
    if (cf != NULL) {
        CFRelease(cf);
    }
}

- (UIImage *)getIconBitmapWithSvg:(NSString *)svgIcon width:(CGFloat)width height:(CGFloat)height color:(UIColor *)color {
    
    NSString *colorKey =
    color != nil ? [NSString stringWithFormat:@"%f %f %f %f", CGColorGetComponents(
                                                                                   color.CGColor)[0], CGColorGetComponents(color.CGColor)[1], CGColorGetComponents(
                                                                                                                                                                   color.CGColor)[2], CGColorGetComponents(color.CGColor)[3]] : @"";
    NSString *key = [NSString stringWithFormat:@"%d %f %f %@", [svgIcon hash], width, height, colorKey];
    
    UIImage *cachedImage = [[self cache] objectForKey:key];
    if (cachedImage != nil) {
        return cachedImage;
    }
    
    SVGKImage *svgImage = [SVGKImage imageWithSource:[SVGKSourceString sourceFromContentsOfString:svgIcon]];
    svgImage.size = CGSizeMake(width, height);
    UIImage *svgImageUI = svgImage.UIImage;
    
    if (color != nil) {
        svgImageUI = [svgImageUI imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(svgImageUI.size, NO, svgImageUI.scale);
        [color set];
        [svgImageUI drawInRect:CGRectMake(0, 0, svgImageUI.size.width, svgImageUI.size.height)];
        svgImageUI = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [[self cache] setObject:svgImageUI forKey:key];
    
    return svgImageUI;
}

- (UIImage *)getMarkerBitmapFromElements:(CozyMarkerElements *)cozyElements {
    CozyMarkerElement *canvasElement = cozyElements.canvas;
    CozyMarkerElement *bubble = cozyElements.bubble;
    CozyMarkerElement *shadowBubble = cozyElements.shadowBubble;
    NSArray < CozyMarkerElement * > *labels = cozyElements.labels;
    CozyMarkerElement *icon = cozyElements.icon;
    CozyMarkerElement *iconCircle = cozyElements.iconCircle;
    CozyMarkerElement *pointer = cozyElements.pointer;
    CozyMarkerElement *counter = cozyElements.counter;
    
    /* start of drawing */
    // creating canvas
    UIGraphicsBeginImageContext(canvasElement.bounds.size);
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:canvasElement.bounds.size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull
                                                  rendererContext) {
        
        // setting colors and stroke
        CGContextSetAlpha(rendererContext.CGContext, 1.0);
        CGContextSetFillColorWithColor(rendererContext.CGContext, bubble.fillColor.CGColor);

        // setting shadow if exists
        if(shadowBubble.alpha != 0) {
            UIColor *shadowColor = [shadowBubble.fillColor colorWithAlphaComponent:shadowBubble.alpha];
            CGFloat deltaX = shadowBubble.bounds.origin.x - bubble.bounds.origin.x;
            CGFloat deltaY = shadowBubble.bounds.origin.y - bubble.bounds.origin.y;
            CGContextSetShadowWithColor(rendererContext.CGContext, CGSizeMake(deltaX,  deltaY), self.shadowBlurSize, shadowColor.CGColor);
        }
        CGContextSetStrokeColorWithColor(rendererContext.CGContext, bubble.strokeColor.CGColor);
        CGContextSetLineJoin(rendererContext.CGContext, 0);
        
        // drawing bubble from point x/y, and with width and height
        UIBezierPath *bubblePath = [UIBezierPath bezierPathWithRoundedRect:bubble.bounds cornerRadius:100];
        
        // add pointer to shape if needed
        if (pointer.bounds.size.height > 0) {
            UIBezierPath *pointerPath = [UIBezierPath bezierPath];
            
            [pointerPath moveToPoint:pointer.bounds.origin];
            [pointerPath addLineToPoint:CGPointMake(CGRectGetMidX(pointer.bounds),
                                                    CGRectGetMaxY(pointer.bounds))];
            [pointerPath addLineToPoint:CGPointMake(CGRectGetMaxX(pointer.bounds),
                                                    CGRectGetMinY(pointer.bounds))];
            [pointerPath closePath];
            [bubblePath appendPath:pointerPath];
        }
        
        // draws the bubble with the pointer, if used
        [bubblePath setLineWidth:self.strokeSize];
        [bubblePath stroke];
        [bubblePath fill];

        // resetting shadow
        if(shadowBubble.alpha != 0) {
            CGContextSetShadowWithColor(rendererContext.CGContext, CGSizeMake(0,  2.0f), 4.0f, nil);
        }
        
        // draws the counter bubble
        if (counter.data != NULL) {
            UIBezierPath *counterBubblePath = [UIBezierPath bezierPathWithRoundedRect:counter.bounds cornerRadius:100];
            
            CGContextSetFillColorWithColor(rendererContext.CGContext, counter.fillColor.CGColor);
            [counterBubblePath fill];
        }
        
        const CGFloat fontSize = 12;
        UIFont *textFont = [UIFont fontWithName:self.fontPath size:fontSize];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        
        // draws the text
        for (CozyMarkerElement *label in labels) {
            if (label.data != NULL) {
                NSString *text = label.data;
                [text drawInRect:CGRectIntegral(label.bounds) withAttributes:@{
                    NSFontAttributeName: textFont, NSParagraphStyleAttributeName: paragraphStyle,
                    NSForegroundColorAttributeName: [label.fillColor colorWithAlphaComponent:label.alpha]}];
            }
        }
        
        // draws the icon
        if (icon.alpha > 0 && icon.data != NULL && [icon.data isKindOfClass:[NSString class]]) {
            UIColor *iconCircleColorWithAlpha = [iconCircle.fillColor colorWithAlphaComponent:iconCircle.alpha];
            CGContextSetFillColorWithColor(rendererContext.CGContext,
                                           iconCircleColorWithAlpha.CGColor);
            CGContextSetLineWidth(rendererContext.CGContext, 0);
            
            CGContextBeginPath(rendererContext.CGContext);
            CGContextAddEllipseInRect(rendererContext.CGContext, iconCircle.bounds);
            CGContextDrawPath(rendererContext.CGContext, kCGPathFill);
            
            UIImage *iconBitmap = [self getIconBitmapWithSvg:icon.data width:icon.bounds.size.width height:icon.bounds.size.height color:icon.fillColor];
            [iconBitmap drawInRect:icon.bounds blendMode:kCGBlendModeNormal alpha:icon.alpha];
        }
    }];
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)getMarkerBitmapWithData:(CozyMarkerData *)cozyMarkerData {
    CozyMarkerElements *cozyElements = [self.cozyMarkerElementsBuilder cozyElementsFromData:cozyMarkerData];
    return [self getMarkerBitmapFromElements:cozyElements];
}

- (UIImage *)getInterpolatedMakerBitmapWithData:(CozyMarkerData *)startMarkerData endMarkerData:(CozyMarkerData *)endMarkerData step:(CGFloat)step {
    CozyMarkerElements *startCozyElements = [self.cozyMarkerElementsBuilder cozyElementsFromData:startMarkerData];
    CozyMarkerElements *endCozyElements = [self.cozyMarkerElementsBuilder cozyElementsFromData:endMarkerData];
    
    CozyMarkerElements *interpolatedCozyElements = [self.cozyMarkerInterpolator getInterpolatedMarkerElementsWithStart:startCozyElements end:endCozyElements step:step];
    return [self getMarkerBitmapFromElements:interpolatedCozyElements];
}

- (UIImage *)buildMarkerWithData:(CozyMarkerData *)cozyMarkerData {
    NSString *key = [cozyMarkerData description];
    UIImage *cachedImage = [[self cache] objectForKey:key];
    if (cachedImage != nil) {
        return cachedImage;
    }
    UIImage *image = [self getMarkerBitmapWithData:cozyMarkerData];
    [[self cache] setObject:image forKey:key];
    return image;
}

- (UIImage *)buildInterpolatedMarkerWithData:(CozyMarkerData *)startMarkerData endMarkerData:(CozyMarkerData *)endMarkerData step:(CGFloat)step {
    NSString *key = [NSString stringWithFormat:@"%@ %@ %f", [startMarkerData description], [endMarkerData description], step];
    UIImage *cachedImage = [[self cache] objectForKey:key];
    if (cachedImage != nil) {
        return cachedImage;
    }
    UIImage *image = [self getInterpolatedMakerBitmapWithData:startMarkerData endMarkerData:endMarkerData step:step];
    [[self cache] setObject:image forKey:key];
    return image;
}

@end

