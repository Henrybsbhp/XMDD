//
//  NSNumber+Format.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Format)

- (NSString *)decimalStringWithMaxFractionDigits:(NSUInteger)maxDigits minFractionDigits:(NSUInteger)minDigits;
/// 四舍五入到小数点后两位，末尾为0则不显示
- (NSString *)priceString;

@end
