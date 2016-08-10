//
//  GasChargedOrderModel.h
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GasChargedOrderModel : NSObject

/// 支付时间
@property (nonatomic, assign) long long payedTime;

/// 交易类型 （分期加油：FQJY，其他加油：APP。只有分期加油才会跳转详情）
@property (nonatomic, copy) NSString *tradeType;

/// 订单记录 ID
@property (nonatomic, assign) NSInteger orderID;

/// 油卡类型（1: 中石油，2: 中石化）
@property (nonatomic, assign) NSInteger cardType;

/// 油卡卡号
@property (nonatomic, copy) NSString *gasCardNum;

/// 记录状态（2: 交易中，3: 交易成功，4: 退款中，5: 退款完成）
@property (nonatomic) NSInteger status;

/// 状态说明（2: 交易中，3: 交易成功，4: 退款中，5: 退款完成）
@property (nonatomic, copy) NSString *statusDesc;

/// 支付金额（实际支付金额）
@property (nonatomic, assign) CGFloat payMoney;

/// 充值说明（快速充值，95/98 折分期充值）
@property (nonatomic, copy) NSString *chargeTips;

/// 充值金额（油卡实际充值金额）
@property (nonatomic, assign) CGFloat chargeMoney;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;

@end
