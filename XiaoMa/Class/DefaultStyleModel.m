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
#import <IQKeyboardManager.h>

@implementation DefaultStyleModel

+ (void)setupDefaultStyle
{
    //TabBar
    [UITabBar appearance].tintColor = kDefTintColor;
    //导航条
//    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].tintColor = kDefTintColor;
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 1)]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"cm_nav_shadow"]];
    //TableCell
    [JTTableViewCell appearance].customSeparatorInset = UIEdgeInsetsMake(-1, 12, 0, 12);
    
    //定制键盘样式
    if (!IOSVersionGreaterThanOrEqualTo(@"7.0")) {
        [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder = NO;
    }
    
}

///弹出视图（默认样式是从底部弹出）
+ (MZFormSheetController *)bottomAppearSheetCtrlWithSize:(CGSize)size
                                          viewController:(UIViewController *)vc
                                              targetView:(UIView *)targetView
{
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.cornerRadius = 0;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    sheet.shouldDismissOnBackgroundViewTap = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    sheet.portraitTopInset = CGRectGetHeight(targetView.frame) - vc.view.frame.size.height;
    return sheet;
}

///弹出视图（默认样式是从底部弹出）
+ (MZFormSheetController *)bottomAppearSheetCtrlWithSize:(CGSize)size
                                          viewController:(UIViewController *)vc
                                              targetViewFrame:(CGRect)targetViewFrame
{
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.cornerRadius = 0;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    sheet.shouldDismissOnBackgroundViewTap = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    sheet.portraitTopInset = CGRectGetHeight(targetViewFrame) - vc.view.frame.size.height;
    return sheet;
}

+ (MZFormSheetController *)presentSheetCtrlFromBottomWithSize:(CGSize)size
                                               viewController:(UIViewController *)vc
                                                   targetView:(UIView *)view
{
    MZFormSheetController *sheet = [self bottomAppearSheetCtrlWithSize:size viewController:vc targetView:view];
    [sheet presentAnimated:YES completionHandler:nil];
    return sheet;
}


+ (MZFormSheetController *)presentSheetCtrlFromBottomWithSize:(CGSize)size
                                               viewController:(UIViewController *)vc
                                                   targetViewFrame:(CGRect)targetViewFrame
{
    MZFormSheetController *sheet = [self bottomAppearSheetCtrlWithSize:size viewController:vc targetViewFrame:targetViewFrame];
    [sheet presentAnimated:YES completionHandler:nil];
    return sheet;
}

@end
