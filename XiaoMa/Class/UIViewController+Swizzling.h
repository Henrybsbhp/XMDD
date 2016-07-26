//
//  UIViewController+Swizzling.h
//  XiaoMa
//
//  Created by jt on 16/1/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Swizzling)

+ (void)patchForViewController;

- (void)sw_viewDidAppear:(BOOL)animated;
- (void)sw_viewDidDisappear:(BOOL)animated;

@end
