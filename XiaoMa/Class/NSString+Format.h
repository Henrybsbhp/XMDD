//
//  NSString+Format.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/17.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Format)

///(舍去小数点后两位)
+ (NSString *)formatForFloorPrice:(double)price;
///(四舍五入小数点后两位 ，小数末尾为0则舍去)
+ (NSString *)formatForRoundPrice:(double)price;
///(四舍五入小数点后两位)
+ (NSString *)formatForRoundPrice2:(double)price;
///(四舍五入小数点后两位)，如果是整数，显示12.00
+ (NSString *)formatForRoundPrice3:(double)price;

@end
