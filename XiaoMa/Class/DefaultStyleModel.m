//
//  DefaultStyleModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DefaultStyleModel.h"
#import <UIKit/UIKit.h>
#import "XiaoMa.h"

@implementation DefaultStyleModel

+ (void)setupDefaultStyle
{
    //TabBar
    [UITabBar appearance].tintColor = kDefTintColor;
    //导航条
    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].tintColor = kDefTintColor;
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 1)]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"cm_nav_shadow"]];
    //TableCell
    [JTTableViewCell appearance].customSeparatorInset = UIEdgeInsetsMake(-1, 12, 0, 12);
}

@end
