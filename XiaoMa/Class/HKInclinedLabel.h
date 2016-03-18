//
//  HKLabel.h
//  test
//
//  Created by RockyYe on 16/3/2.
//  Copyright © 2016年 RockyYe. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  斜45度的label
 */
@interface HKInclinedLabel : UIView

/**
 *  文本
 */
@property (strong, nonatomic) NSString *text;
/**
 *  文本颜色
 */
@property (strong, nonatomic) UIColor *textColor;
/**
 *  背景颜色
 */
@property (strong, nonatomic) UIColor *trapeziumColor;
/**
 *  字体大小。不设置则自动适应
 */
@property (nonatomic) CGFloat fontSize;


@end
