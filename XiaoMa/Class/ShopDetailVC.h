//
//  ShopDetailVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTableViewController.h"
#import "JTShop.h"

@class HKCoupon;

@interface ShopDetailVC : HKViewController

@property (nonatomic, strong)JTShop * shop;
@property (nonatomic, strong)HKCoupon * couponFordetailsDic;

@property (nonatomic)BOOL needRequestShopComments;
@property (nonatomic)BOOL needPopToFirstCarwashTableVC;

@property (nonatomic, weak) UIViewController *originVC;

@end
