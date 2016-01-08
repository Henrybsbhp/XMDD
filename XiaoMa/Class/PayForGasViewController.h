//
//  PayForGasViewController.h
//  XiaoMa
//
//  Created by jt on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GasCard.h"
#import "GasNormalVM.h"
#import "AppManager.h"
#import "CouponModel.h"
#import "HKCoupon.h"

@interface PayForGasViewController : HKViewController

@property (nonatomic,copy)NSString * payTitle;
@property (nonatomic,copy)NSString * paySubTitle;

@property (nonatomic,strong)GasNormalVM * model;
/// 充值金额
@property (nonatomic)NSInteger rechargeAmount;

/// 为优惠劵选择服务,选中>0,不选中=0
@property (nonatomic)CouponType couponType;
/// 选中的优惠劵
@property (nonatomic,strong)NSMutableArray * selectGasCoupouArray;

@property (nonatomic, weak) UIViewController *originVC;

@end
