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

- (CKStoreEvent *)getAllInsOrders
{
    GetInsuranceOrderListOp * op = [GetInsuranceOrderListOp operation];
    RACSignal *sig = [[op rac_postRequest] map:^id(GetInsuranceOrderListOp *rspOp) {
        JTQueue *cache = [[JTQueue alloc] init];
        for (HKInsuranceOrder *order in rspOp.rsp_orders) {
            [cache addObject:order forKey:order.orderid];
        }
        self.cache = cache;
        return rspOp.rsp_orders;
    }];
    return [CKStoreEvent eventWithSignal:sig code:kCKStoreEventReload object:nil];
}

- (CKStoreEvent *)getInsOrderByID:(NSNumber *)orderID
{
    GetInsuranceOrderDetailsOp * op = [GetInsuranceOrderDetailsOp operation];
    op.req_orderid = orderID;
    RACSignal *sig = [[op rac_postRequest] map:^id(GetInsuranceOrderDetailsOp *rspOp) {
        [self.cache addObject:rspOp.rsp_order forKey:rspOp.rsp_order.orderid];
        return rspOp.rsp_order;
    }];
    return [CKStoreEvent eventWithSignal:sig code:kInsOrderStoreEventReloadOne object:nil];
}

- (void)reloadDataWithCode:(NSInteger)code
{
    [self sendEvent:[self getAllInsOrders]];
}

@end
