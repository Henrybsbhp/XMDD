//
//  ChooseBankCardVC.h
//  XiaoMa
//
//  Created by jt on 15/8/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyBankVC.h"
@class HKMyCar;
@interface ChooseBankCardVC : HKViewController
@property (nonatomic, strong) HKMyCar * defaultCar;

@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) JTShopService *service;
@property (nonatomic, strong) NSArray *bankCards;
@property (nonatomic, strong) NSArray *carwashCouponArray;
/**
 *  是否需要重新选择优惠券。（如果原先有选的券，则为NO）
 */
@property (nonatomic)BOOL needRechooseCarwashCoupon;


@end
