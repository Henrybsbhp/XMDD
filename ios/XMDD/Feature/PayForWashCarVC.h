//
//  PayForWashCarVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTShop.h"
#import "HKCoupon.h"

@class HKMyCar;

@interface PayForWashCarVC : HKViewController

@property (nonatomic, strong) JTShopService *service;
@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) HKMyCar *defaultCar;
/// 去使用带过来的优惠券
@property (nonatomic, strong) HKCoupon *coupon;
@property (nonatomic, weak) UIViewController *originVC;

/// 为优惠劵选择服务
@property (nonatomic)CouponType couponType;
@property (nonatomic,strong)NSDictionary * selectBankCard;
@property (nonatomic,strong)NSMutableArray * selectCarwashCoupouArray;
@property (nonatomic,strong)NSMutableArray * selectCashCoupouArray;

/// 是否自动选择。（优惠劵去使用后进入的页面此值为YES）
@property (nonatomic)BOOL isAutoCouponSelect;

@property (nonatomic)BOOL needChooseResource;

- (void)tableViewReloadData;
///添加好银行卡后的自动选择优惠劵方法
- (void)chooseResource;
- (void)setPaymentChannel:(PaymentChannelType)channel;

- (void)requestGetUserResource:(BOOL)needAutoSelect;


@end
