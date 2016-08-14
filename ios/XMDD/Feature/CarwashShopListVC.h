//
//  CarwashShopListVC.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "JTShop.h"
#import "HKCoupon.h"

@interface CarwashShopListVC : HKViewController
@property (nonatomic, assign) ShopServiceType serviceType;
@property (nonatomic, strong) HKCoupon *coupon;
@end
