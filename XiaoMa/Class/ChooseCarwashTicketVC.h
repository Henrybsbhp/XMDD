//
//  ChooseWashCarTicketVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKCoupon.h"

@interface ChooseCarwashTicketVC : UIViewController

@property (nonatomic, weak) UIViewController *originVC;

@property (nonatomic,strong)NSArray * couponArray;
@property (nonatomic,strong)NSMutableArray * selectedCouponArray;

@property (nonatomic)CouponType type;

@property (nonatomic)CGFloat upperLimit;
@property (nonatomic)CGFloat numberLimit;

@end
