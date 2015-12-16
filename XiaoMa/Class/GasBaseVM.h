//
//  GasBaseVM.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentHelper.h"
#import "GasCard.h"
#import "HKBankCard.h"
#import "HKStore.h"
#import "GasCardStore.h"

#define kGasConsumeEventForModel    997
#define kGasVCReloadDirectly        998
#define kGasVCReloadWithEvent       999


@interface GasBaseVM : NSObject

@property (nonatomic, assign) BOOL isLoading;
///(Default is YES)
@property (nonatomic, assign) BOOL isLoadSuccess;
///当前选择的油卡
@property (nonatomic, strong) GasCard *curGasCard;
///当前选择的银行卡
@property (nonatomic, strong) HKBankCard *curBankCard;
///充值金额
@property (nonatomic, assign) NSUInteger rechargeAmount;
///优惠金额
@property (nonatomic, assign) NSUInteger discountAmount;
///支付平台
@property (nonatomic, assign) PaymentPlatformType paymentPlatform;
///check box control
@property (nonatomic, strong) CKSegmentHelper *segHelper;
@property (nonatomic, strong) GasCardStore *cardStore;

///是否需要发票
@property (nonatomic, assign) BOOL needInvoice;
///加油提醒
- (NSString *)gasRemainder;
///充值优惠描述
- (NSString *)rechargeFavorableDesc;
///@Override
- (NSArray *)datasource;
///@Override(银行卡优惠描述)
- (NSString *)bankFavorableDesc;
///@Override
- (BOOL)reloadWithForce:(BOOL)force;
///@Override
- (void)setupCardStore;
///@Override
- (void)consumeEvent:(HKStoreEvent *)event;
- (NSString *)recentlyUsedGasCardKey;

@end
