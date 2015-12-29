//
//  NSString+Format.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/17.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "NSString+Format.h"

@implementation NSString (Format)

///(舍去小数点后两位)
+ (NSString *)formatForFloorPrice:(double)price
{
    int integer = floor(price);
    int remain = floor((price - integer) * 100);
    if (remain > 0) {
        remain = remain%10 == 0 ? remain/10 : remain;
        return [NSString stringWithFormat:@"%d.%d", integer, remain];
    }
    return [NSString stringWithFormat:@"%d", integer];
}

///(四舍五入小数点后两位 ，小数末尾为0则舍去)
+ (NSString *)formatForRoundPrice:(double)price
{
    int integer = floor(price);
    int remain = floor((price - integer) * 1000);
    if (remain % 10 >= 5) {
        remain = remain/10 + 1;
        if (remain >= 100) {
            remain -= 100;
            integer += 1;
        }
    }
    if (remain > 0) {
        remain = remain%10 == 0 ? remain/10 : remain;
        return [NSString stringWithFormat:@"%d.%d", integer, remain];
    }
    return [NSString stringWithFormat:@"%d", integer];
}

///(四舍五入小数点后两位)
+ (NSString *)formatForRoundPrice2:(double)price
{
    int integer = floor(price);
    int remain = floor((price - integer) * 1000);
    if (remain % 10 >= 5) {
        remain = remain/10 + 1;
        if (remain >= 100) {
            remain -= 100;
            integer += 1;
        }
    }
    else {
        remain = remain/10;
    }
    if (remain > 0) {
        return [NSString stringWithFormat:@"%d.%d", integer, remain];
    }
    return [NSString stringWithFormat:@"%d", integer];
}
@end
