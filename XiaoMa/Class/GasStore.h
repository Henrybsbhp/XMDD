//
//  GasStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "CKQueue.h"
#import "GetGaschargeConfigOp.h"

#define kDomainGasCards           @"gasCards"
#define kDomainReloadNormalGas    @"normalReload"
#define kDomainReloadCZBGas       @"czbReload"

@interface GasStore : UserStore

@property (nonatomic, strong) CKQueue *gasCards;
///普通充值配置信息
@property (nonatomic, strong) GetGaschargeConfigOp *config;
///充值套餐(包括普通充值)
@property (nonatomic, strong) NSArray *chargePackages;

///获取当前用户所有油卡
- (CKEvent *)getAllGasCards;

@end
