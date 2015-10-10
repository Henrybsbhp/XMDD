//
//  InsOrderStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsOrderStore.h"
#import "GetInsuranceOrderListOp.h"
#import "GetInsuranceOrderDetailsOp.h"

#define kInsOrderStoreEventReloadOne    100

@implementation InsOrderStore

- (RACSignal *)rac_getAllInsOrders
{
    GetInsuranceOrderListOp * op = [GetInsuranceOrderListOp operation];
    return [[op rac_postRequest] map:^id(GetInsuranceOrderListOp *rspOp) {
        JTQueue *cache = [[JTQueue alloc] init];
        for (HKInsuranceOrder *order in rspOp.rsp_orders) {
            [cache addObject:order forKey:order.orderid];
        }
        self.cache = cache;
        return rspOp.rsp_orders;
    }];
}

- (RACSignal *)rac_getInsOrderByID:(NSNumber *)orderID
{
    GetInsuranceOrderDetailsOp * op = [GetInsuranceOrderDetailsOp operation];
    op.req_orderid = orderID;
    return [[op rac_postRequest] map:^id(GetInsuranceOrderDetailsOp *rspOp) {
        [self.cache addObject:rspOp.rsp_order forKey:rspOp.rsp_order.orderid];
        return rspOp.rsp_order;
    }];
}

- (void)reloadDataWithCode:(NSInteger)code
{
    [self sendEvent:[self rac_getAllInsOrders] withCode:kCKStoreEventReload];
}

+ (void)reloadOrderByID:(NSNumber *)orderid
{
    InsOrderStore *store = [self fetchExistsStore];
    [store sendEvent:[store rac_getInsOrderByID:orderid] withCode:kInsOrderStoreEventReloadOne];
}

@end
