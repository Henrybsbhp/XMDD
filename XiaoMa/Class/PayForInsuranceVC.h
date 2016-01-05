//
//  PayForInsuranceVC.h
//  XiaoMa
//
//  Created by jt on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKInsuranceOrder.h"
#import "HKCoupon.h"
#import "InsuranceVM.h"

@interface PayForInsuranceVC : UIViewController

@property (nonatomic, strong) InsuranceVM *insModel;
@property (nonatomic,strong)HKInsuranceOrder * insOrder;


/// 为优惠劵选择服务
@property (nonatomic)CouponType couponType;
/// 是否选择活动
@property (nonatomic)BOOL isSelectActivity;

@property (nonatomic,strong)NSMutableArray * selectInsuranceCoupouArray;


- (void)requestGetUserInsCoupon;
- (void)tableViewReloadData;


@end
