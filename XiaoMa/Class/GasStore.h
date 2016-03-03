//
//  GasStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "CKQueue.h"
#import "GasCard.h"
#import "GetGaschargeConfigOp.h"

#define kReloadNormalGas          @"normalGas"
#define kDomainGasCards           @"gasCards"
#define kDomainUpadteGasCardInfo  @"updateGasCardInfo"
#define kDomainChargeConfig       @"chargeConfig"

@interface GasStore : UserStore

@property (nonatomic, strong) CKQueue *gasCards;
///当前普通加油选中的油卡(如果油卡不为空，则表示该油卡一定还有普通充值信息)
@property (nonatomic, strong) GasCard *curNormalGasCard;

///普通充值配置信息
@property (nonatomic, strong) GetGaschargeConfigOp *config;
///充值套餐(包括普通充值)
@property (nonatomic, strong) CKQueue *chargePackages;

///获取当前用户所有油卡
- (CKEvent *)getAllGasCards;
///更新油卡信息
- (CKEvent *)updateCardInfoByGID:(NSNumber *)gid;
///获取油卡配置信息
- (CKEvent *)getChargeConfig;
@end
