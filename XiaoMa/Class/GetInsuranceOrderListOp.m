//
//  GetInsuranceOrderListOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetInsuranceOrderListOp.h"

@implementation GetInsuranceOrderListOp

- (RACSignal *)rac_postRequesØt
{
    self.req_method = @"/user/order/insurance/get";
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *orderArray = [NSMutableArray array];
    for (NSDictionary *orderDict in dict[@"orders"]) {
        HKInsuranceOrder *order = [HKInsuranceOrder orderWithJSONResponse:orderDict];
        [orderArray safetyAddObject:order];
    }
    self.rsp_orders = orderArray;
    return self;
}

- (id)returnSimulateResponse
{
    return @{@"rc":@0, @"orders":@[], @"id":@17, @"newmsg":@0};
}

@end
