//
//  UIBarButtonItem+CustomStyle.h
//  EasyPay
//
//  Created by jiangjunchen on 14-10-17.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (CustomStyle)

+ (instancetype)backBarButtonItemWithTarget:(id)target action:(SEL)action;

+ (instancetype)webBackButtonItemWithTarget:(id)target action:(SEL)action;

+ (instancetype)closeButtonItemWithTarget:(id)target action:(SEL)action;

+ (instancetype)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

//- (void)setTarget:(id)target withAction:(SEL)action;

@end
