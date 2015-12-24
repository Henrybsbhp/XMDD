//
//  ChooseBankCardVC.h
//  XiaoMa
//
//  Created by jt on 15/8/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyBankVC.h"
@class HKMyCar;
@interface ChooseBankCardVC : UIViewController
@property (nonatomic, strong) HKMyCar * defaultCar;

@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) JTShopService *service;
@property (nonatomic, strong) NSArray *bankCards;
@property (nonatomic, strong) NSArray *carwashCouponArray;


@end
