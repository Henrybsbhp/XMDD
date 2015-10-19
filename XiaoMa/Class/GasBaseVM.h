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

@interface GasBaseVM : NSObject

@property (nonatomic, assign) BOOL isLoading;
///(Default is NO)
@property (nonatomic, assign) BOOL isLoadSuccess;
///当前选择的油卡
@property (nonatomic, strong) GasCard *curGasCard;
///当前选择的银行卡
@property (nonatomic, strong) HKBankCard *curBankCard;
///充值金额
@property (nonatomic, assign) NSUInteger rechargeAmount;
///支付平台
@property (nonatomic, assign) PaymentPlatformType paymentPlatform;
///是否同意协议(Default is YES)
@property (nonatomic, assign) BOOL isAcceptedAgreement;
///check box control
@property (nonatomic, strong) CKSegmentHelper *segHelper;

///加油提醒
- (NSString *)gasRemainder;
///充值优惠描述
- (NSString *)rechargeFavorableDesc;
///@Override
- (NSArray *)datasource;
///@Override(银行卡优惠描述)
- (NSString *)bankFavorableDesc;
@end
