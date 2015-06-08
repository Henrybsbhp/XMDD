//
//  NSString+RectSize.h
//  ECP4iPhone
//
//  Created by jtang on 12-6-1.
//  Copyright (c) 2012年 jtang.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RectSize)
/// 获取指定字体、最大宽度下的最佳size（普通文本）
- (CGSize)labelSizeWithWidth:(int)width font:(UIFont *)font;
@end
