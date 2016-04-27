//
//  NSString+Price.m
//  XiaoMa_Owner
//
//  Created by jt on 15-7-3.
//  Copyright (c) 2015年 hk. All rights reserved.
//

#import "NSString+Price.h"

@implementation NSString (Price)

+ (BOOL)isPureFloat:(NSString *)string

{
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    float val;
    
    return [scan scanFloat:&val] && [scan isAtEnd];
}

+ (BOOL)isPureInt:(NSString *)string

{
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (NSString *)formatForDiscount:(CGFloat)discount
{
    NSString * originStr = [NSString stringWithFormat:@"%.1f",discount];
    NSString * decimal = [originStr substringFromIndex:originStr.length - 1];
    NSString * displayStr = originStr;
    if ([decimal isEqualToString:@"0"])
    {
        displayStr = [originStr substringToIndex:originStr.length - 2];
    }
    
    return displayStr;
}

+ (NSString *)formatForPrice:(CGFloat)price
{
    NSString * originStr = [NSString stringWithFormat:@"%.2f",price];
    NSString * decimal = [originStr substringFromIndex:originStr.length - 2];
    NSString * displayStr = originStr;
    if ([decimal isEqualToString:@"00"])
    {
        displayStr = [originStr substringToIndex:originStr.length - 3];
    }
    
    return displayStr;
}

+ (NSString *)formatForPrice:(CGFloat)price maxPrice:(NSInteger)digit
{
    NSString * originStr = [NSString stringWithFormat:@"%.2f",price];
    NSString * integerStr = [originStr substringToIndex:originStr.length - 3];
    NSString * decimal = [originStr substringFromIndex:originStr.length - 2];
    NSString * displayStr = originStr;
    if (integerStr.length >= digit)
    {
        return integerStr;
    }
    else
    {
        if ([decimal isEqualToString:@"00"])
        {
            displayStr = [originStr substringToIndex:originStr.length - 3];
        }
        return displayStr;
    }
}

+ (NSString *)formatForPriceWithFloat:(CGFloat)price
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    NSString *priceTag = [formatter stringFromNumber:[NSNumber numberWithFloat:price]];
    if ([priceTag hasSubstring:@"."])
    {
        return priceTag;
    }
    else
    {
        return [priceTag append:@".00"];
    }
    
}

@end
