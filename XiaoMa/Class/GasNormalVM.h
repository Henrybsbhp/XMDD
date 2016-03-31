//
//  GasVM.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GasBaseVM.h"
#import "GetGaschargeConfigOp.h"
#import "GascardChargeOp.h"

@interface GasNormalVM : GasBaseVM
@property (nonatomic, strong) GetGaschargeConfigOp *configOp;
///充值套餐(包括普通充值)
@property (nonatomic, strong) NSArray *chargePackages;
@property (nonatomic, strong) GasChargePackage *curChargePackage;
///分期加油充值金额
@property (nonatomic, assign) NSInteger instalmentRechargeAmount;
@property (nonatomic, assign) NSInteger normalRechargeAmount;
@property (nonatomic, strong) HKStoreEvent *cachedEvent;

- (NSArray *)datasource;
///充值优惠描述
- (NSString *)rechargeFavorableDesc;
- (void)startPayInTargetVC:(UIViewController *)vc
                   success:(void(^)(GasCard *card, GascardChargeOp *paidop))success
                    failed:(void(^)(NSError *error, GascardChargeOp *op))fail;

@end
