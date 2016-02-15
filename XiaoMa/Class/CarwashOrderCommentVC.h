//
//  CarwashOrderCommentVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKServiceOrder.h"

@interface CarwashOrderCommentVC : HKViewController
@property (nonatomic, strong) HKServiceOrder *order;
@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, copy) void (^commentSuccess)(void);
@end
