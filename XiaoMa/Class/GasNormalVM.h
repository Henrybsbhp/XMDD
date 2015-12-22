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
@property (nonatomic, strong) HKStoreEvent *cachedEvent;

///充值优惠描述
- (NSString *)rechargeFavorableDesc;
- (void)startPayInTargetVC:(UIViewController *)vc completed:(void(^)(GasCard *card, GascardChargeOp *paidop))completed;

@end
