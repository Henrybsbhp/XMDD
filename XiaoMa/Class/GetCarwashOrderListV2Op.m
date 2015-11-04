//
//  GetCarwashOrderListV2Op.m
//  XiaoMa
//
//  Created by jt on 15/11/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetCarwashOrderListV2Op.h"

@implementation GetCarwashOrderListV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/order/service/v2/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.req_tradetime > 0) {
        [params setObject:@(self.req_tradetime) forKey:@"tradetime"];
    }
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *orderArray = [NSMutableArray array];
    for (NSDictionary *orderDict in dict[@"orders"]) {
        HKServiceOrder *order = [HKServiceOrder orderWithJSONResponse:orderDict];
        [orderArray safetyAddObject:order];
    }
    self.rsp_orders = orderArray;
    return self;
}


@end
