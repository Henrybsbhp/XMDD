//
//  UIView+CustomForXIB.m
//  EasyPay
//
//  Created by jiangjunchen on 14/10/31.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "UIView+CustomForXIB.h"
#import <objc/runtime.h>
#import <CKKit.h>
#import <FoundationExtension.h>

static char *s_keyPathKey;
@implementation UIView (CustomXIB)
@dynamic keyPath;

+ (void)patchForCustomXIB
{
    [self _copyToSelector:@selector(awakeFromNib) fromSelector:@selector(_customXIB_awakeFromNib) forObject:self];
}

- (void)setKeyPath:(NSString *)keyPath
{
    objc_setAssociatedObject(self, &s_keyPathKey, keyPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)keyPath
{
    return objc_getAssociatedObject(self, &s_keyPathKey);
}

- (void)_customXIB_awakeFromNib
{
    if (![self isKindOfClass:[UIView class]])
    {
        return;
    }
    NSString *code = self.keyPath;
    if (code.length == 0)
    {
        return;
    }

    NSArray *properties = [code componentsSeparatedByString:@"#"];
    for (NSString *property in properties)
    {
        [self _applyProperty:property];
    }
}

+ (void)_copyToSelector:(SEL)toSelector fromSelector:(SEL)fromSelector forObject:(id)object{
    NSAMethod *toMethod = [object methodObjectForSelector:toSelector];
    NSAMethod *fromMethod = [object methodObjectForSelector:fromSelector];
    toMethod.implementation = fromMethod.implementation;
}


- (void)_applyProperty:(NSString *)property
{
    if (property.length == 0)
    {
        return;
    }
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@".+(?=_.)" options:0 error:nil];
    NSString *key = [self _matchedStringWithRegexp:regexp inString:property];
    
    
    regexp = [NSRegularExpression regularExpressionWithPattern:@"(?<=._).+" options:0 error:nil];
    NSString *value = [self _matchedStringWithRegexp:regexp inString:property];
    
    if ([key equalByCaseInsensitive:@"BC"]) {
        self.layer.borderColor = [self _colorWithString:value].CGColor;
    }
    else if ([key equalByCaseInsensitive:@"BW"]) {
        self.layer.borderWidth = [value floatValue];
    }
    else if ([key equalByCaseInsensitive:@"CR"]) {
        self.layer.cornerRadius = [value floatValue];
    }
    //normal image contentInsets
    else if([key equalByCaseInsensitive:@"CI"]) {
        UIEdgeInsets insets = [self edgeInsetsWithString:value];
        if ([self isKindOfClass:[UIButton class]]) {
            [self _setButton:(UIButton *)self withImageInsets:insets forState:UIControlStateNormal];
        }
        else if ([self isKindOfClass:[UIImageView class]]) {
            [self _setImageView:(UIImageView *)self withImageInsets:insets forHighlight:NO];
        }
    }
    else if ([key equalByCaseInsensitive:@"BCI"]) {
        UIEdgeInsets insets = [self edgeInsetsWithString:value];
        if ([self isKindOfClass:[UIButton class]]) {
            UIImage *img = [(UIButton *)self backgroundImageForState:UIControlStateNormal];
            img = [img resizableImageWithCapInsets:insets];
            [(UIButton *)self setBackgroundImage:img forState:UIControlStateNormal];
        }
    }
    else if ([key equalByCaseInsensitive:@"HCI"]) {
        UIEdgeInsets insets = [self edgeInsetsWithString:value];
        if ([self isKindOfClass:[UIButton class]]) {
            [self _setButton:(UIButton *)self withImageInsets:insets forState:UIControlStateHighlighted];
        }
        else if ([self isKindOfClass:[UIImageView class]]) {
            [self _setImageView:(UIImageView *)self withImageInsets:insets forHighlight:YES];
        }
    }
    else if ([key equalByCaseInsensitive:@"HBCI"]) {
        UIEdgeInsets insets = [self edgeInsetsWithString:value];
        if ([self isKindOfClass:[UIButton class]]) {
            UIImage *img = [(UIButton *)self backgroundImageForState:UIControlStateHighlighted];
            img = [img resizableImageWithCapInsets:insets];
            [(UIButton *)self setBackgroundImage:img forState:UIControlStateHighlighted];
        }
    }
}

- (void)_setButton:(UIButton *)btn withImageInsets:(UIEdgeInsets)insets forState:(UIControlState)state
{
    UIImage *img = [(UIButton *)self imageForState:state];
    img = [img resizableImageWithCapInsets:insets];
    [btn setImage:img forState:state];
}

- (void)_setImageView:(UIImageView *)imgV withImageInsets:(UIEdgeInsets)insets forHighlight:(BOOL)highlight
{
    if (highlight) {
        UIImage *img = imgV.highlightedImage;
        imgV.highlightedImage = [img resizableImageWithCapInsets:insets];
    }
    else {
        UIImage *img = imgV.image;
        imgV.image = [img resizableImageWithCapInsets:insets];
    }
}

- (NSString *)_matchedStringWithRegexp:(NSRegularExpression *)regexp inString:(NSString *)string
{
    NSRange range = [regexp rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (range.location != NSNotFound) {
        return [string substringWithRange:range];
    }
    return nil;
}

- (NSArray *)_matchedArrayWithRegexp:(NSRegularExpression *)regexp inString:(NSString *)string
{
    NSTextCheckingResult *result = [regexp firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < result.numberOfRanges; i++)
    {
        [array addObject:[string substringWithRange:[result rangeAtIndex:i]]];
    }
    return array;
}

- (UIEdgeInsets)edgeInsetsWithString:(NSString *)string
{
    NSString *pattern = @"(.+),(.+),(.+),(.+)";
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray *values = [self _matchedArrayWithRegexp:regexp inString:string];
    if (values.count == 5) {
        return UIEdgeInsetsMake([(NSNumber *)values[1] floatValue], [(NSNumber *)values[2] floatValue],
                                [(NSNumber *)values[3] floatValue], [(NSNumber *)values[4] floatValue]);
    }
    return UIEdgeInsetsZero;
}

- (UIColor *)_colorWithString:(NSString *)string
{
    NSString *pattern = @"RGBA\\((.+),(.+),(.+),(.+)\\)";
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray *values = [self _matchedArrayWithRegexp:regexp inString:string];
    if (values.count == 5) {
        return RGBACOLOR([(NSNumber *)values[1] floatValue], [(NSNumber *)values[2] floatValue],
                         [(NSNumber *)values[3] floatValue], [(NSNumber *)values[4] floatValue]);
    }
    
    pattern = @"RGB\\((.+),(.+),(.+)\\)";
    regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    values = [self _matchedArrayWithRegexp:regexp inString:string];
    if (values.count == 4) {
        return RGBCOLOR([(NSNumber *)values[1] floatValue],
                        [(NSNumber *)values[2] floatValue], [(NSNumber *)values[3] floatValue]);
    }

    return nil;
}
@end
