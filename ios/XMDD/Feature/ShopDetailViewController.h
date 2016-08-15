//
//  ShopDetailViewController.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "JTShop.h"
#import "HKCoupon.h"

@interface ShopDetailViewController : HKViewController

@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) HKCoupon *coupon;
@property (nonatomic, assign) ShopServiceType serviceType;

@end
