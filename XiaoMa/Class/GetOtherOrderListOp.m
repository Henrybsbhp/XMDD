//
//  GetOtherOrderListOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetOtherOrderListOp.h"

@implementation GetOtherOrderListOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/otherorder/his/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.req_payedtime >= 0) {
        [params setObject:@(self.req_payedtime) forKey:@"payedtime"];
    }
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *orderArray = [NSMutableArray array];
    for (NSDictionary *orderDict in dict[@"orders"]) {
        HKOtherOrder *order = [HKOtherOrder orderWithJSONResponse:orderDict];
        [orderArray safetyAddObject:order];
    }
    self.rsp_orders = orderArray;
    return self;
}

@end
