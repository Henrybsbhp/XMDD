//
//  PayForWashCarVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTShop.h"
#import "HKCoupon.h"
#import "CheckoutServiceOrderV2Op.h"

@class HKMyCar;
@class HKBankCard;

@interface PayForWashCarVC : UIViewController

@property (nonatomic, strong) JTShopService *service;
@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) HKMyCar * defaultCar;
@property (nonatomic, weak) UIViewController *originVC;

/// 为优惠劵选择服务
@property (nonatomic)CouponType couponType;
@property (nonatomic)HKBankCard * selectBankCard;
@property (nonatomic,strong)NSMutableArray * selectCarwashCoupouArray;
@property (nonatomic,strong)NSMutableArray * selectCashCoupouArray;

- (void)setPlatform:(PaymentPlatform)platform;
- (void)tableViewReloadData;

- (void)requestGetUserResource;

@end
