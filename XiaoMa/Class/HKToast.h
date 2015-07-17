//
//  HKToast.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKToast : UIView

+ (instancetype)sharedTosast;

- (void)showingWithText:(NSString *)test;
- (void)showSuccess:(NSString *)success;
- (void)showError:(NSString *)error;
- (void)showError:(NSString *)error inView:(UIView *)view;
- (void)showText:(NSString *)text;
- (void)showingWithText:(NSString *)text inView:(UIView *)view;
- (void)dismissInView:(UIView *)view;
- (void)dismiss;

@end
