//
//  MyCouponVC.h
//  XiaoMa
//
//  Created by Yawei Liu on 15/5/8.
//  Copyright (c) 2015年 Hangzhou Huika Tech.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKCoupon.h"

@interface MyCouponVC : UIViewController

@property (nonatomic, assign) CouponNewType jumpType;

@property (nonatomic, weak) UIViewController *originVC;

@end
