//
//  CouponDetailsVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKCoupon.h"

@interface CouponDetailsVC : UIViewController

///优惠劵Id
@property (nonatomic, strong)NSNumber * couponId;

///是否可分享
@property (nonatomic, assign)BOOL isShareble;

///优惠券颜色
@property (nonatomic, strong)NSString * rgbStr;

///优惠券类型（旧）
@property (nonatomic, assign)CouponType oldType;

///优惠券类型（新）
@property (nonatomic, assign)CouponNewType newType;

@property (nonatomic, weak) UIViewController *originVC;

@end
