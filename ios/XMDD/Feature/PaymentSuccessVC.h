//
//  PaymentSuccessVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKServiceOrder.h"

typedef enum : NSUInteger {
    BeforeComment,
    Commenting,
    Commented,
    CommentError
} CommentStatus;

@interface PaymentSuccessVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;

@property (nonatomic,strong)HKServiceOrder * order;

@property (nonatomic)CommentStatus commentStatus;

@property (nonatomic, copy) void (^commentSuccess)(void);


@end
