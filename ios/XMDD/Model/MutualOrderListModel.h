//
//  MutualOrderListModel.h
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
@class InsuranceOrderListModel;
@class MutualOrderListModel;

@interface MutualOrderListModel : NSObject

///订单id
@property (nonatomic, strong)NSNumber *contractid;
/// 车牌号码
@property (nonatomic, copy) NSString *licenseNumber;

/// 车标 logo 地址
@property (nonatomic, copy) NSString *brandLogoAddress;

/// 订单创建时间
@property (nonatomic, copy) NSString *createTime;

/// 互助开始时间
@property (nonatomic, copy) NSString *insStartTime;

/// 互助结束时间
@property (nonatomic, copy) NSString *insEndTime;

/// 互助金
@property (nonatomic, assign) float sharedMoney;

/// 服务费
@property (nonatomic, assign) float memberFee;

/// 总支付金额
@property (nonatomic, assign) float fee;

/// 状态（1: 待支付，2: 交易完成，10: 已退款）
@property (nonatomic, assign) NSInteger status;

/// 状态描述（1: 待支付，2: 交易完成，10: 已退款）
@property (nonatomic, copy) NSString *statusDesc;

/// 交强险信息
@property (nonatomic, strong) InsuranceOrderListModel *forceInfo;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;

@end


@interface InsuranceOrderListModel : NSObject
/// 交强险费用
@property (nonatomic, copy) NSString *forceFee;

/// 车船费费用
@property (nonatomic, assign) float taxShipFee;

/// 购买交强险公司
@property (nonatomic, copy) NSString *insComp;

/// 交强险开始日期
@property (nonatomic, copy) NSString *forceStartDate;

/// 交强险结束日期
@property (nonatomic, copy) NSString *forceEndDate;

/// 保险 logo 地址
@property (nonatomic, copy) NSString *proxyLogo;

/// 订单创建时间
@property (nonatomic, copy) NSString *createTime;

+ (instancetype)orderWithDict:(NSDictionary *)dict;

@end
