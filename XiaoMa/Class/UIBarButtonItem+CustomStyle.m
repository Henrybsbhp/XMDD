//
//  UIBarButtonItem+CustomStyle.m
//  EasyPay
//
//  Created by jiangjunchen on 14-10-17.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "UIBarButtonItem+CustomStyle.h"
#import "CKKit.h"
#import "NSString+RectSize.h"

@implementation UIBarButtonItem (CustomStyle)


+ (instancetype)backBarButtonItemWithTarget:(id)target action:(SEL)action
{
    UIImage *img = [UIImage imageNamed:@"nav_back_300"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain
                                                            target:target action:action];
    item.tintColor = kDefTintColor;
    return item;
}

+ (instancetype)webBackButtonItemWithTarget:(id)target action:(SEL)action
{
    UIImage *img = [UIImage imageNamed:@"cm_nav_webback"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain
                                                            target:target action:action];
    item.tintColor = kDefTintColor;
    return item;
}

+ (instancetype)closeButtonItemWithTarget:(id)target action:(SEL)action
{
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:target action:action];
    [close setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:16.0]} forState:UIControlStateNormal];
    return close;
}

+ (instancetype)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize textSize = [title labelSizeWithWidth:110 font:font];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitleColor:kDefTintColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, ceil(textSize.width + 8), 30);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

//- (void)setTarget:(id)target withAction:(SEL)action
//{
//    self.target = target;
//    self.action = action;
//}

@end
