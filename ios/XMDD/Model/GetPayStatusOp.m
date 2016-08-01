//
//  GetPayStatusOp.m
//  XiaoMa
//
//  Created by RockyYe on 16/4/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetPayStatusOp.h"

@implementation GetPayStatusOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/order/paystatus/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_tradetype forName:@"tradetype"];
    [params addParam:self.req_tradeno forName:@"tradeno"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(NSDictionary *)rspObj
{

    NSNumber *status = rspObj[@"status"];
    self.rsp_status = status.integerValue == 1 ? YES : NO;
    return self;
}

- (NSString *)description
{
    return @"获取订单状态支付状态";
}

@end
