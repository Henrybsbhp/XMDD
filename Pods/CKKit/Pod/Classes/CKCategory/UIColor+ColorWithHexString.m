//
//  UIColor+ColorWithHexString.m
//  ECP4iPhone
//
//  Created by JTang_Mini_02 on 12-9-27.
//  Copyright (c) 2012年 jtang.com.cn. All rights reserved.
//
#import "UIColor+ColorWithHexString.h"

@implementation UIColor (ColorWithHexString)

+ (UIColor *)colorWithHex:(NSString *)hexColor alpha:(CGFloat)fAlapa
{
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;

    range.location = 1;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];

    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:fAlapa];
}

- (NSString *)getHexString
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString = [NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}
@end
