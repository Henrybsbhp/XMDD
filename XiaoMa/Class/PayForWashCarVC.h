//
//  PayForWashCarVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTShop.h"

@class HKMyCar;

@interface PayForWashCarVC : UIViewController

@property (nonatomic, strong) JTShopService *service;
@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) HKMyCar * defaultCar;
@property (nonatomic, weak) UIViewController *originVC;

- (void)setCouponId:(NSString *)couponId;

- (void)setPaymentType:(PaymentChannelType)paymentType;

- (void)tableViewReloadData;

@end
