//
//  CheckGeneralTradenoStatusOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CheckGeneralTradenoStatusOp.h"

@implementation CheckGeneralTradenoStatusOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/unioncard/quickpay/checkout";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_tradeno forName:@"tradeno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_status = dict[@"status"];
    return self;
}

@end
