//
//  InsuranceOrderPayOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceOrderPayOp.h"

@implementation InsuranceOrderPayOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/order/insurance/v2/pay";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params addParam:@(self.req_paychannel) forName:@"paychannel"];
    [params addParam:self.req_orderid forName:@"orderid"];
    [params addParam:self.req_cid ? self.req_cid : @"" forName:@"cid"];
    [params addParam:@(self.req_type) forName:@"type"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_total = [dict floatParamForName:@"total"];
    self.rsp_tradeno = [dict objectForKey:@"tradeno"];
    return self;
}

@end
