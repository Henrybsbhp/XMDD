//
//  GetCarwashOrderOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetCarwashOrderOp.h"

@implementation GetCarwashOrderOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/order/service/detail/get/by-id";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_orderid forName:@"orderid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_order = [HKServiceOrder orderWithJSONResponse:dict[@"order"]];
    return self;
}

@end
