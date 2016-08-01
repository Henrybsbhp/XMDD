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


- (void)showingWithoutText;
///带风火轮的提示
- (void)showingWithText:(NSString *)text;
///带风火轮的提示（有效作用域view）
- (void)showingWithText:(NSString *)text inView:(UIView *)view;
///带打钩标示的提示
- (void)showSuccess:(NSString *)success;
///不带叉叉的提示
- (void)showError:(NSString *)error;
///不带叉叉的提示（有效作用域view）
- (void)showError:(NSString *)error inView:(UIView *)view;
/**
 *  带叉叉的提示
 *
 *  @param mistake 文本
 */
- (void)showMistake:(NSString *)mistake;
///弱提示
- (void)showText:(NSString *)text;
///弱提示（有效作用域view）
- (void)showText:(NSString *)text inView:(UIView *)view;
///提示消失（有效作用域view）
- (void)dismissInView:(UIView *)view;
///提示消失
- (void)dismiss;

@end
