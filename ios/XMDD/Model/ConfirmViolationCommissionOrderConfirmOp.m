//
//  ConfirmViolationCommissionOrderConfirmOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ConfirmViolationCommissionOrderConfirmOp.h"

@implementation ConfirmViolationCommissionOrderConfirmOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/order/confirm";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
   [params addParam:self.req_recordid forName:@"recordid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_money = rspObj[@"money"];
    self.rsp_servicefee = rspObj[@"servicefee"];
    self.rsp_totalfee = rspObj[@"totalfee"];
    self.rsp_servicename = rspObj[@"servicename"];
    self.rsp_servicepicurl = rspObj[@"servicepicurl"];
    return self;
}


- (NSString *)description
{
    return @"确认用户违章代办订单支付信息";
}

@end
