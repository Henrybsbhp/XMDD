//
//  RequestForRescueCommissionOrderOp.h
//  XMDD
//
//  Created by St.Jimmy on 24/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"
#import "PayInfoModel.h"

@interface RequestForRescueCommissionOrderOp : BaseOp

/// 申请记录 ID（输入参数）
@property (nonatomic, strong) NSNumber *req_applyID;

/// 支付渠道（输入参数）
@property (nonatomic) PaymentChannelType req_payChannel;

/// 支付金额（输入参数）
@property (nonatomic, strong) NSNumber *req_payAmount;

/// 服务名称（输入参数）
@property (nonatomic, copy) NSString *req_serviceName;

/// 车牌号码（输入参数）
@property (nonatomic, copy) NSString *req_licenseNumber;

/// 交易 ID（返回参数）
@property (nonatomic, copy) NSString *rsp_tradeID;

/// 支付信息（返回参数）
@property (nonatomic, strong) PayInfoModel *rsp_payInfoModel;

@end
