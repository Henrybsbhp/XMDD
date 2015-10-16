//
//  NSString+Price.h
//  XiaoMa_Owner
//
//  Created by jt on 15-7-3.
//  Copyright (c) 2015年 hk. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSString (Price)

+ (BOOL)isPureFloat:(NSString *)string;
+ (BOOL)isPureInt:(NSString *)string;

/**
 *  小数为零的截断
 *
 *  @param price price
 *
 *  @return nsstring
 */
+ (NSString *)formatForPrice:(CGFloat)price;

/**
 *  忽略小数的金额
 *
 *  @param price price
 *  @param digit 忽略小数的金额最大整数位数
 *
 *  @return NSString
 *  11111.13 digit == 5 return 11111
 *  11111.13 digit == 6 return 11111.13
 */
+ (NSString *)formatForPrice:(CGFloat)price maxPrice:(NSInteger)digit;
@end
