//
//  HKProgressView.h
//  XiaoMa
//
//  Created by jt on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKView.h"

@interface HKProgressView : UIView

/**
 *  提示数组
 */
@property (nonatomic,strong)NSArray * titleArray;

/**
 *  高亮颜色，默认为浅绿色
 */
@property (nonatomic,strong)UIColor * highlightColor;

/**
 *  非高亮颜色，默认为灰色
 */
@property (nonatomic,strong)UIColor * normalColor;

/**
 *  高亮文本颜色，默认为白色
 */
@property (nonatomic,strong)UIColor * highlightTextColor;

/**
 *  非高亮文本颜色，默认为深灰色
 */
@property (nonatomic,strong)UIColor * normalTextColor;

/**
 *  高亮的元素索引
 */
@property (nonatomic)NSInteger selectedIndex;


@end
