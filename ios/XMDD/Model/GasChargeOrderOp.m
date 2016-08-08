//
//  GasChargeOrderOp.m
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GasChargeOrderOp.h"

@implementation GasChargeOrderOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/gascharge/order/his/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.payedTime > 0) {
        [params setObject:@(self.payedTime) forKey:@"payedtime"];
    }
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *orderArray = [NSMutableArray array];
    for (NSDictionary *orderDict in dict[@"gaschargeddatas"]) {
        GasChargedOrderModel *order = [GasChargedOrderModel orderWithJSONResponse:orderDict];
        [orderArray safetyAddObject:order];
    }
    self.gasChargedData = orderArray;
    return self;
}

@end
