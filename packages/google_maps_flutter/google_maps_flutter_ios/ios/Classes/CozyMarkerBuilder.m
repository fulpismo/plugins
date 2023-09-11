//
//  CozyMarkerBuilder.m
//  google_maps_flutter_ios
//
//  Created by Luiz Carvalho on 16/02/23.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CozyMarkerBuilder.h"
#import "CozyMarkerData.h"
#import <SVGKit/SVGKit.h>

@implementation CozyMarkerBuilder


- (instancetype)initWithCache:(BOOL)useCache {
    self = [super init];
    if(self) {
        _fontPath = [self loadCozyFont];
        _useCache = useCache;
        if(useCache == YES) {
            _cache = [[NSCache alloc] init];
        }
    }
    return self;
}

- (NSString *)loadCozyFont {
    CGFontRef font = [self fontRefFromBundle];
    [self registerFont:font];
    NSString *fontName = (__bridge NSString *)CGFontCopyPostScriptName(font);
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
    NSBundle *bundle = [NSBundle  bundleWithURL:bundleURL];
    NSURL *fontURL = [bundle URLForResource:@"oatmealpro2_semibold" withExtension:@"otf"];
    NSData *inData = [NSData dataWithContentsOfURL:fontURL];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    CFSafeRelease(provider);
    return font;
}

void CFSafeRelease(CFTypeRef cf) {
    if (cf != NULL) {
        CFRelease(cf);
    }
}

- (UIImage *)getIconBitmapWithSvg:(NSString *)svgIcon width:(CGFloat)width height:(CGFloat) height color:(UIColor *)color {
    //update key
    UIImage *cachedImage = [[self cache] objectForKey:svgIcon];
    if(cachedImage != nil) {
        return cachedImage;
    }
    
    SVGKImage *svgImage = [SVGKImage imageWithSource:[SVGKSourceString sourceFromContentsOfString:svgIcon]];
    svgImage.size = CGSizeMake(width, height);
    UIImage* svgImageUI = svgImage.UIImage;

    if(color != nil){
        svgImageUI = [svgImageUI imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(svgImageUI.size, NO, svgImageUI.scale);
        [color set];
        [svgImageUI drawInRect:CGRectMake(0, 0, svgImageUI.size.width, svgImageUI.size.height)];
        svgImageUI = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [[self cache] setObject:svgImageUI forKey:svgIcon];

    return svgImageUI;
}

- (UIImage *)getMarkerWithData:(CozyMarkerData *)cozyMarkerData {
    NSString *text = cozyMarkerData.label;
    NSString *icon = cozyMarkerData.icon;
    NSString *chevronIcon = cozyMarkerData.chevronIcon;
    BOOL hasPointer = cozyMarkerData.hasPointer;

    /* setting colors */
    UIColor *defaultMarkerColor = UIColor.whiteColor;
    UIColor *defaultTextColor = UIColor.blackColor;
    UIColor *defaultIconCircleColor = [UIColor colorWithRed:(248.0f/255.0f) green:(249.f/255.0f) blue:(245.0f/255.0f) alpha:1];
    UIColor *defaultChevronIconColor = UIColor.blackColor;
    
    UIColor *selectedMarkerColor = [UIColor colorWithRed:(57.0f/255.0f) green:(87.0f/255.0f) blue:(189.0f/255.0f) alpha:1];
    UIColor *selectedTextColor = UIColor.whiteColor;
    UIColor *selectedIconCircleColor = UIColor.whiteColor;
    UIColor *selectedChevronIconColor = UIColor.whiteColor;
    
    UIColor *visualizedMarkerColor = [UIColor colorWithRed:(248.0f/255.0f) green:(249.0f/255.0f) blue:(245.0f/255.0f) alpha:1];
    UIColor *visualizedTextColor = [UIColor colorWithRed:(110.0f/255.0f) green:(110.0f/255.0f) blue:(100.0f/255.0f) alpha:1];
    UIColor *visualizedIconCircleColor = UIColor.whiteColor;

    UIColor *markerColor = defaultMarkerColor;
    UIColor *textColor = defaultTextColor;
    UIColor *iconCircleColor = defaultIconCircleColor;
    UIColor *chevronIconColor = defaultChevronIconColor;
    UIColor *strokeColor = [UIColor colorWithRed:212.0f/255.0f green:(214.0f/255.0f) blue:(202.0f/255.0f) alpha:1];
    
    if(cozyMarkerData.isVisualized){
        markerColor = visualizedMarkerColor;
        textColor = visualizedTextColor;
        iconCircleColor = visualizedIconCircleColor;
    }
    if(cozyMarkerData.isSelected){
        markerColor = selectedMarkerColor;
        textColor = selectedTextColor;
        iconCircleColor = selectedIconCircleColor;
        chevronIconColor = selectedChevronIconColor;
    }

    /* setting constants */
    // setting padding and stroke size
    CGFloat paddingVertical = 10.5f;
    CGFloat paddingHorizontal = 11;
    CGFloat minMarkerWidth = 40;
    CGFloat strokeSize = 3;

    // setting constants for pointer
    CGFloat pointerWidth = 6;
    CGFloat pointerHeight = 5;

    // setting constants for icon
    CGFloat iconSize = 16;
    CGFloat iconCircleSize = 24;
    CGFloat iconLeftPadding = 5;
    CGFloat iconRightPadding = 3;

    // setting constants for chevron
    CGFloat chevronSize = 24;
    CGFloat chevronRightPadding = 11;
    CGFloat chevronLeftPadding = 8;

    /* setting variables */
    // getting font and setting its size to 3 the size of the marker size
    CGFloat fontSize = 12;
    UIFont *textFont =  [UIFont fontWithName:self.fontPath size:fontSize];
    CGSize stringSize = [text sizeWithAttributes:@{NSFontAttributeName:textFont}];

    // additionalIconWidth to be used on markerWidth
    CGFloat iconAdditionalWidth = icon != NULL ? iconCircleSize + iconRightPadding : 0;
    CGFloat chevronAdditionalWidth = chevronIcon != NULL ? chevronLeftPadding + chevronSize : 0;
    
    // pointerSize to be used on bitmap creation
    CGFloat pointerSize = hasPointer ? pointerHeight : 0;
    
    // setting marker width with a minimum width in case the string size is below the minimum
    CGFloat markerWidth = stringSize.width + (2 * paddingHorizontal) + (2 * strokeSize) + iconAdditionalWidth + chevronAdditionalWidth;
    if(markerWidth < minMarkerWidth) {
        markerWidth = minMarkerWidth;
    }
    
    // set the marker height as the string height with space for padding and stroke
    CGFloat markerHeight = stringSize.height + (2 * paddingVertical) + 2 * strokeSize;

    // gets a bubble path, centering in a space for stroke on the left and top side
    CGFloat bubbleShapeWidth = markerWidth - strokeSize * 2;
    CGFloat bubbleShapeHeight = markerHeight - strokeSize * 2;

    // other important variables
    CGFloat middleOfMarkerY = (bubbleShapeHeight / 2) + strokeSize;

    /* start of drawing */
    // creating canvas
    CGSize canvas = CGSizeMake(markerWidth, markerHeight + pointerSize);
    UIGraphicsBeginImageContext(canvas);
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize: canvas];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        
        // setting colors and stroke
        CGContextSetAlpha(rendererContext.CGContext, 1.0);
        CGContextSetFillColorWithColor(rendererContext.CGContext, markerColor.CGColor);
        CGContextSetStrokeColorWithColor(rendererContext.CGContext, strokeColor.CGColor);
        CGContextSetLineJoin(rendererContext.CGContext, 0);
        
        // drawing bubble from point x/y, and with width and height
        UIBezierPath *bubblePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(strokeSize, strokeSize, bubbleShapeWidth, bubbleShapeHeight) cornerRadius:100];
        
        // add pointer to shape if needed
        if(hasPointer) {
            CGFloat x = canvas.width / 2;
            CGFloat y = markerHeight - strokeSize;
            
            UIBezierPath *pointerPath = [UIBezierPath bezierPath];
            [pointerPath moveToPoint:CGPointMake(x - pointerWidth, y)];
            [pointerPath addLineToPoint:CGPointMake(x, y + pointerHeight)];
            [pointerPath addLineToPoint:CGPointMake(x + pointerWidth, y)];
            [pointerPath closePath];
            [bubblePath appendPath:pointerPath];
        }
        
        // draws the bubble with the pointer, if used
        [bubblePath setLineWidth: strokeSize];
        [bubblePath stroke];
        [bubblePath fill];
     
        // draws the text
        CGFloat textY = middleOfMarkerY - (stringSize.height / 2);
        CGFloat textX = (canvas.width / 2) - (stringSize.width / 2) + iconAdditionalWidth/2 - chevronAdditionalWidth/2;
        
        CGRect textRect = CGRectMake(textX, textY, stringSize.width, stringSize.height);
        [text drawInRect:CGRectIntegral(textRect) withAttributes:@{NSFontAttributeName:textFont, NSForegroundColorAttributeName: textColor}];
        
        if(icon != NULL){
            CGContextSetFillColorWithColor(rendererContext.CGContext, defaultIconCircleColor.CGColor);
            CGContextSetLineWidth(rendererContext.CGContext, 0);

            CGContextBeginPath(rendererContext.CGContext);
            CGContextAddEllipseInRect(rendererContext.CGContext, CGRectMake(strokeSize + iconLeftPadding, middleOfMarkerY - iconCircleSize/2,iconCircleSize,iconCircleSize));
            CGContextDrawPath(rendererContext.CGContext, kCGPathFill);

            UIImage *iconBitmap = [self getIconBitmapWithSvg:icon width:iconSize height:iconSize color:NULL];
            [iconBitmap drawInRect:CGRectMake(strokeSize + iconLeftPadding + (iconCircleSize - iconSize)/2, middleOfMarkerY - iconSize/2,iconSize,iconSize)];
        }

        if(chevronIcon != NULL){
            UIImage *chevronBitmap = [self getIconBitmapWithSvg:chevronIcon width:chevronSize height:chevronSize color:chevronIconColor];
            [chevronBitmap drawInRect:CGRectMake(canvas.width - chevronSize - chevronRightPadding - strokeSize, middleOfMarkerY - chevronSize/2,chevronSize,chevronSize)];
        }
    }];
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)cacheMarkerWithData:(CozyMarkerData *)cozyMarkerData {
    NSString *key = [cozyMarkerData description];
    UIImage *cachedImage = [[self cache] objectForKey:key];
    if(cachedImage != nil) {
        return cachedImage;
    }
    UIImage *image = [self getMarkerWithData:cozyMarkerData];
    [[self cache] setObject:image forKey:key];
    return image;
}

- (UIImage *)buildMarkerWithData:(CozyMarkerData *)cozyMarkerData {
    if(_useCache == YES) {
        return [self cacheMarkerWithData:cozyMarkerData];
    }
    return [self getMarkerWithData:cozyMarkerData];
}

    
@end

