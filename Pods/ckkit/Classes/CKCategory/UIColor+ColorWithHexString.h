//
//  UIColor+ColorWithHexString.h
//  ECP4iPhone
//
//  Created by JTang_Mini_02 on 12-9-27.
//  Copyright (c) 2012年 jtang.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
* 将十六进制的颜色值转换为UIColor的categroy
*/
@interface UIColor (ColorWithHexString)

/// 十六进制->RGB 必须是 #xxxxxx
+ (UIColor *)colorWithHex:(NSString *)hexColor alpha:(CGFloat)fAlapa;
- (NSString *)getHexString;
@end
