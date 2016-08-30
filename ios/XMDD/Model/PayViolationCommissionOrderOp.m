//
//  payViolationCommissionOrderOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "PayViolationCommissionOrderOp.h"

@implementation PayViolationCommissionOrderOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/order/pay";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_recordid forName:@"recordid"];
    [params addParam:self.req_paychannel forName:@"paychannel"];
    [params addParam:self.req_couponid forName:@"couponid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_totalfee = [rspObj floatParamForName:@"totalfee"];
    self.rsp_tradeno = rspObj[@"tradeno"];
    self.rsp_payInfoModel = [PayInfoModel payInfoWithJSONResponse:rspObj[@"payinfo"]];
    return self;
}



- (NSString *)description
{
    return @"用户违章代办订单支付";
}

@end
