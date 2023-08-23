//
//  CozyMarkerBuilder.m
//  google_maps_flutter_ios
//
//  Created by Luiz Carvalho on 16/02/23.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CozyMarkerBuilder.h"


@implementation CozyMarkerBuilder


- (instancetype)initWithCache:(BOOL)useCache {
    self = [super init];
    if(self) {
        _fontPath = [self loadCozyFont];
        _markerSize = [self calculateMarkerSize];
        _shadowWidth = 3;
        _useCache = useCache;
        if(useCache == YES) {
            _cache = [[NSCache alloc] init];
        }
    }
    return self;
}

- (CGFloat)calculateMarkerSize {
    CGFloat baseScreenHeight = 2220;
    CGFloat maxMarkerRadius = 155;
    CGFloat minMarkerRadius = 60;
    CGFloat devicePixelRatio = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;
    CGFloat proportionalMarkerRadius = 150 * (devicePixelRatio / baseScreenHeight);   
    if(proportionalMarkerRadius > maxMarkerRadius) {
        return maxMarkerRadius;
    } else if (proportionalMarkerRadius < minMarkerRadius) {
        return minMarkerRadius;
    }
    return proportionalMarkerRadius;
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

- (UIImage *)baseMarker {
    CGFloat size = ([self markerSize] / [UIScreen mainScreen].scale) + [self shadowWidth];
    CGSize canvas = CGSizeMake(size, size);
    UIGraphicsBeginImageContext(canvas);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize: canvas];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextSetAlpha(rendererContext.CGContext, 0.02);
        CGContextSetFillColorWithColor(rendererContext.CGContext, UIColor.grayColor.CGColor);
        CGContextAddEllipseInRect(rendererContext.CGContext, CGRectMake(0, 0, size, size));
        CGContextDrawPath(rendererContext.CGContext, kCGPathFillStroke);
        CGContextSetAlpha(rendererContext.CGContext, 1.0);
        CGContextSetFillColorWithColor(rendererContext.CGContext, UIColor.whiteColor.CGColor);
        CGContextSetStrokeColorWithColor(rendererContext.CGContext, UIColor.clearColor.CGColor);
        CGContextSetLineWidth(rendererContext.CGContext, 10);
        CGContextAddEllipseInRect(rendererContext.CGContext, CGRectMake([self shadowWidth] / 2, [self shadowWidth] / 2, size - [self shadowWidth], size - [self shadowWidth]));
        CGContextDrawPath(rendererContext.CGContext, kCGPathFillStroke);
    }];
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)clusterMarkerImageWithText:(NSString *)string {
    UIImage *circle = [self baseMarker];
    CGSize size = [circle size];
    UIFont *textFont = [UIFont fontWithName:self.fontPath size:size.width / 2.5];
    CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName:textFont}];
    CGFloat textY = (size.height / 2) - (stringSize.height / 2);
    CGFloat textX = (size.width / 2) - (stringSize.width / 2);
    UIGraphicsBeginImageContext(size);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        [circle drawInRect:CGRectIntegral(rect)];
        CGRect textRect = CGRectMake(textX, textY, stringSize.width, stringSize.height);
        [string drawInRect:CGRectIntegral(textRect) withAttributes:@{NSFontAttributeName:textFont}];
    }];
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)priceMarkerImageWithText:(NSString *)text {
    CGFloat fontSize = ([self markerSize] / [UIScreen mainScreen].scale) / 3;
    UIFont *textFont = [UIFont fontWithName:self.fontPath size:fontSize];
    CGSize stringSize = [text sizeWithAttributes:@{NSFontAttributeName:textFont}];
    
    CGFloat padding = fontSize;
    CGFloat markerWidth = stringSize.width + padding;
    CGFloat markerHeight = stringSize.height + padding;
    
    CGSize canvas = CGSizeMake(markerWidth + 2, markerHeight + 10);
    CGFloat y = ((canvas.height - 10) / 2) - (stringSize.height / 2);
    CGFloat x = (canvas.width / 2) - (stringSize.width / 2);
    CGRect textRect = CGRectMake(x, y, stringSize.width, stringSize.height);
    UIGraphicsBeginImageContext(canvas);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize: canvas];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        
        CGFloat heightWithoutShadow = markerHeight - [self shadowWidth];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, canvas.width / 2 - 10, heightWithoutShadow);
        CGPathAddLineToPoint(path, nil, canvas.width / 2, heightWithoutShadow + 10);
        CGPathAddLineToPoint(path, nil, canvas.width / 2 + 10, heightWithoutShadow);
        CGPathAddLineToPoint(path, nil, canvas.width / 2 - 10, heightWithoutShadow);
        
        CGContextSetAlpha(rendererContext.CGContext, 0.02);
        CGContextSetFillColorWithColor(rendererContext.CGContext, UIColor.grayColor.CGColor);
        UIBezierPath *shadow = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, markerWidth, markerHeight) cornerRadius:7];
        [shadow fill];
        [shadow stroke];
        CGContextSetAlpha(rendererContext.CGContext, 1.0);
        CGContextSetFillColorWithColor(rendererContext.CGContext, UIColor.whiteColor.CGColor);
        CGContextSetStrokeColorWithColor(rendererContext.CGContext, UIColor.clearColor.CGColor);
        CGContextSetLineWidth(rendererContext.CGContext, 5);
        CGContextSetLineJoin(rendererContext.CGContext, 0);
        CGContextAddPath(rendererContext.CGContext, path);
        CGContextDrawPath(rendererContext.CGContext, 3);
        UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:CGRectMake([self shadowWidth] / 2, [self shadowWidth] / 2, markerWidth - [self shadowWidth], markerHeight - [self shadowWidth]) cornerRadius:7];
        [bezier fill];
        [bezier stroke];
        [text drawInRect:CGRectIntegral(textRect) withAttributes:@{NSFontAttributeName:textFont}];
        CGPathRelease(path);
    }];
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)pinMarkerImageWithText:(NSString *)text withMarkerColor:(UIColor *)color withTextColor:(UIColor *)textColor withTail:(BOOL)withTail {
    
    // getting font and setting its size to 3 the size of the marker size
    CGFloat fontSize = 12;
    UIFont *textFont =  [UIFont fontWithName:self.fontPath size:fontSize];
    CGSize stringSize = [text sizeWithAttributes:@{NSFontAttributeName:textFont}];
    
    // setting padding and stroke size
    CGFloat paddingHorizontal = 11;
    CGFloat paddingVertical = 12;
    CGFloat strokeSize = 3;

    // setting stroke color
    UIColor *strokeColor = [UIColor colorWithRed:212.0f/255.0f green:(214.0f/255.0f) blue:(202.0f/255.0f) alpha:1];

    // setting marker width with a minimum width in case the string size is below the minimum
    CGFloat minMarkerWidth = 40;
    CGFloat markerWidth = stringSize.width + (2 * paddingVertical) + (2 * strokeSize);
    if(markerWidth < minMarkerWidth) {
        markerWidth = minMarkerWidth;
    }
     
    // in case a tail will be used, sets a tail size, else it becomes 0.
    CGFloat tailSize = withTail ? 6 : 0;
    
    // setting the marker height
    CGFloat markerHeight = stringSize.height + (2 * paddingHorizontal) + (2 * strokeSize) + tailSize;

    
    // creating canvas
    CGSize canvas = CGSizeMake(markerWidth, markerHeight);

    UIGraphicsBeginImageContext(canvas);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize: canvas];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        
        // setting colors and stroke
        CGContextSetAlpha(rendererContext.CGContext, 1.0);
        CGContextSetFillColorWithColor(rendererContext.CGContext, color.CGColor);
        CGContextSetStrokeColorWithColor(rendererContext.CGContext, strokeColor.CGColor);
        CGContextSetLineJoin(rendererContext.CGContext, 0);
        
        // drawing bubble from point x/y, and with width and height
        UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(strokeSize, strokeSize, markerWidth - (2 * strokeSize), markerHeight - (2 * strokeSize) - tailSize) cornerRadius:20];
        
        // if a tail will be used, sets a point in the bottom center of the bubble,
        // draws a triangle from this point and adds to the bubble path above
        if(withTail) {
            CGFloat x = canvas.width / 2;
            CGFloat y = markerHeight - tailSize - strokeSize;
            
            UIBezierPath *tailPath = [UIBezierPath bezierPath];
            [tailPath moveToPoint:CGPointMake(x - tailSize, y)];
            [tailPath addLineToPoint:CGPointMake(x, y + tailSize)];
            [tailPath addLineToPoint:CGPointMake(x + tailSize, y)];
            [tailPath closePath];
            [bezier appendPath:tailPath];
        }
        
        // draws the bubble with the tail, if used
        [bezier setLineWidth: strokeSize];
        [bezier stroke];
        [bezier fill];
     
        // draws the text
        CGFloat textY = ((canvas.height - tailSize) / 2) - (stringSize.height / 2);
        CGFloat textX = (canvas.width / 2) - (stringSize.width / 2);
        CGRect textRect = CGRectMake(textX, textY, stringSize.width, stringSize.height);
        [text drawInRect:CGRectIntegral(textRect) withAttributes:@{NSFontAttributeName:textFont, NSForegroundColorAttributeName: textColor}];
        
    }];
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)getMarker:(NSString *)label withMarkerType:(NSString *)markerType withAlpha:(CGFloat)alpha {
    NSString* text = [@((int) (alpha * 100)) stringValue];
    NSLog(@"getMarker: %@", text);
    if([markerType isEqualToString:@"cluster"]) {
        return [self clusterMarkerImageWithText:label];
    }
    else if([markerType isEqualToString:@"price"]) {
        return [self priceMarkerImageWithText:label];
    }
    else if([markerType isEqualToString:@"pin_cluster"]) {
        return [self pinMarkerImageWithText:text withMarkerColor:UIColor.whiteColor withTextColor:UIColor.blackColor withTail:NO];
    } else if([markerType isEqualToString:@"pin_cluster_visited"]) {
        return [self pinMarkerImageWithText:label withMarkerColor:UIColor.whiteColor withTextColor:[UIColor colorWithRed:(110.0f/255.0f) green:(110.0f/255.0f) blue:(100.0f/255.0f) alpha:1] withTail:NO];
    }
    else if([markerType isEqualToString:@"pin_cluster_selected"]) {
        return [self pinMarkerImageWithText:label withMarkerColor:[UIColor colorWithRed:(57.0f/255.0f) green:(87.0f/255.0f) blue:(189.0f/255.0f) alpha:1] withTextColor:UIColor.whiteColor withTail:NO];
    }
    else if([markerType isEqualToString:@"pin_price"]) {
        return [self pinMarkerImageWithText:text withMarkerColor:UIColor.whiteColor withTextColor:UIColor.blackColor withTail:YES];
    }
    else if([markerType isEqualToString:@"pin_price_visited"]) {
        return [self pinMarkerImageWithText:label withMarkerColor:UIColor.whiteColor withTextColor:[UIColor colorWithRed:(110.0f/255.0f) green:(110.0f/255.0f) blue:(100.0f/255.0f) alpha:1] withTail:YES];
    }
    else if([markerType isEqualToString:@"pin_price_selected"]) {
        return [self pinMarkerImageWithText:label withMarkerColor:[UIColor colorWithRed:(57.0f/255.0f) green:(87.0f/255.0f) blue:(189.0f/255.0f) alpha:1] withTextColor:UIColor.whiteColor withTail:YES];
    }
    @throw [NSException exceptionWithName:@"InvalidMarker"
                                       reason:@"markerType not found for icon."
                                     userInfo:nil];
    
}

- (UIImage *)cacheMarkerWithLabel:(NSString *)label withMarkerType:(NSString *)markerType {
    NSString *key = [NSString stringWithFormat:@"%@:%@", markerType, label];
    UIImage *cachedImage = [[self cache] objectForKey:key];
    if(cachedImage != nil) {
        return cachedImage;
    }
    UIImage *image = [self getMarker:label withMarkerType:markerType withAlpha:1];
    [[self cache] setObject:image forKey:key];
    return image;
}

- (UIImage *)buildMarker:(NSString *)label withMarkerType:(NSString *)markerType withAlpha:(CGFloat)alpha {
    if(label == (id)[NSNull null] || [label isEqualToString:@""]) {
        @throw [NSException exceptionWithName:@"InvalidMarker"
                                       reason:@"no label was provided when expected."
                                     userInfo:nil];
    }
    //if(_useCache == YES) {
    //    return [self cacheMarkerWithLabel:label withMarkerType:markerType];
    //}
    return [self getMarker:label withMarkerType:markerType withAlpha:alpha];
}

    
@end

