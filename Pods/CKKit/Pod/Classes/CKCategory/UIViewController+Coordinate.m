//
//  UIViewController+Coordinate.m
//  JTReader
//
//  Created by jiangjunchen on 13-10-10.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "UIViewController+Coordinate.h"

@implementation UIViewController (Coordinate)

- (CGFloat)baseTopY
{
    BOOL statusBarHide = [UIApplication sharedApplication].isStatusBarHidden;
    BOOL navigationBarHide = self.navigationController ? self.navigationController.navigationBarHidden : YES;
    return [self baseTopYWithStatusBarHide:statusBarHide navigatonBarHide:navigationBarHide];
}

- (CGFloat)baseTopYWithStatusBarHide:(BOOL)statusBarHide navigatonBarHide:(BOOL)navigationBarHide
{
    CGFloat y = 0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        if (self.navigationController)
        {
            if (self.navigationController.navigationBar.isTranslucent)
            {
                y += statusBarHide ? 0 : 20;
                y += navigationBarHide ? 0 : self.navigationController.navigationBar.frame.size.height;
            }
        }
        else
        {
            y += statusBarHide ? 0 : 20;
        }
    }
    return y;
}

@end
