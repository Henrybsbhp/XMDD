//
//  UIBarButtonItem+CustomStyle.m
//  EasyPay
//
//  Created by jiangjunchen on 14-10-17.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "UIBarButtonItem+CustomStyle.h"
#import <CKKit.h>

@implementation UIBarButtonItem (CustomStyle)


+ (instancetype)backBarButtonItemWithTarget:(id)target action:(SEL)action
{
    UIImage *img = [UIImage imageNamed:@"nav_back_300"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain
                                                            target:target action:action];
    item.tintColor = HEXCOLOR(@"#18d06a");
    return item;
}

+ (instancetype)webBackButtonItemWithTarget:(id)target action:(SEL)action
{
    UIImage *img = [UIImage imageNamed:@"cm_nav_webback"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain
                                                            target:target action:action];
    item.tintColor = HEXCOLOR(@"#18d06a");
    return item;
}

+ (instancetype)closeButtonItemWithTarget:(id)target action:(SEL)action
{
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:target action:action];
    [close setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:16.0]} forState:UIControlStateNormal];
    return close;
}

//- (void)setTarget:(id)target withAction:(SEL)action
//{
//    self.target = target;
//    self.action = action;
//}

@end
