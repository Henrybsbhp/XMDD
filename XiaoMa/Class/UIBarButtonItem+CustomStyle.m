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
    UIImage *img = [UIImage imageNamed:@"cm_nav_back"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain
                                                            target:target action:action];
    item.tintColor = HEXCOLOR(@"#1bb745");
    return item;
}

//- (void)setTarget:(id)target withAction:(SEL)action
//{
//    self.target = target;
//    self.action = action;
//}

@end
