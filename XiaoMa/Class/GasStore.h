//
//  GasStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "GasCard.h"
#import "HKBankCard.h"
#import "GetGaschargeConfigOp.h"
#import "GetCZBCouponDefInfoOp.h"

#define kDomainGasCards           @"gasCards"
#define kDomainUpadteGasCardInfo  @"updateGasCardInfo"
#define kDomainChargeConfig       @"chargeConfig"

#define kDomainCZBChargeConfig    @"czbChargeConfig"
#define kDomainUpdateCZBCardInfo  @"updateCzbCardInfo"

@interface GasStore : UserStore

@property (nonatomic, strong) JTQueue *gasCards;
///普通充值配置信息
@property (nonatomic, strong) GetGaschargeConfigOp *config;
///充值套餐(包括普通充值)
@property (nonatomic, strong) CKQueue *chargePackages;

///浙商充值配置信息
@property (nonatomic, strong) GetCZBCouponDefInfoOp *czbConfig;

///获取当前用户所有油卡
- (CKEvent *)getAllGasCards;
///添加油卡
- (CKEvent *)addGasCard:(GasCard *)card;
///删除油卡
- (CKEvent *)deleteGasCard:(GasCard *)card;
///更新油卡信息
- (CKEvent *)updateCardInfoByGID:(NSNumber *)gid;
///获取油卡配置信息
- (CKEvent *)getChargeConfig;

///更新浙商卡加油信息
- (CKEvent *)updateCZBCardInfoByCID:(NSNumber *)cid;
///获取浙商充值配置信息
- (CKEvent *)getCZBChargeConfig;

///分期加油充值说明
- (NSString *)rechargeDescriptionForFqjy:(GasChargePackage *)pkg;
///普通加油充值说明
- (NSString *)rechargeDescriptionForNormal:(GasCard *)card;
///浙商卡加油充值说明
- (NSString *)rechargeDescriptionForCZB:(HKBankCard *)bank;
///充值提醒
- (NSString *)gasRemainder;

   
@end
