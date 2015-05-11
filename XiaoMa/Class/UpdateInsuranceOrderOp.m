//
//  UpdateInsuranceOrderOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/24.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UpdateInsuranceOrderOp.h"

@implementation UpdateInsuranceOrderOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/order/insurance/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_deliveryaddress forName:@"deliveryaddress"];
    [params addParam:@(self.req_paychannel) forName:@"paychannel"];
    [params addParam:self.req_orderid forName:@"orderid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (id)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_tradeno = [dict stringParamForName:@"tradeno"];
    self.rsp_premium = [dict floatParamForName:@"premium"];
    return self;
}

@end
