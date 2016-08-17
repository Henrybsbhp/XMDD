//
//  NSNumber+Format.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "NSNumber+Format.h"

@implementation NSNumber (Format)

- (NSString *)decimalStringWithMaxFractionDigits:(NSUInteger)maxDigits minFractionDigits:(NSUInteger)minDigits {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setUsesGroupingSeparator:NO];
    [formatter setMaximumFractionDigits:maxDigits];
    [formatter setMinimumFractionDigits:minDigits];
    return [formatter stringFromNumber:self];
}

- (NSString *)priceString {
    return [self decimalStringWithMaxFractionDigits:2 minFractionDigits:0];
}

@end
