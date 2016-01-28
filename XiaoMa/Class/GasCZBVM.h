//
//  GasCZBVM.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GasBaseVM.h"
#import "GetCZBCouponDefInfoOp.h"

@interface GasCZBVM : GasBaseVM
@property (nonatomic, strong) GetCZBCouponDefInfoOp *defCouponInfo;
@property (nonatomic, strong) HKStoreEvent *cachedEvent;
///银行卡优惠描述
- (NSString *)bankFavorableDesc;
- (void)cancelOrderWithTradeNumber:(NSString *)tdno gasCardID:(NSNumber *)gid;
@end
