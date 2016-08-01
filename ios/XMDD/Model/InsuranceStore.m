//
//  InsuranceStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsuranceStore.h"
#import "GetInsCarListOp.h"
#import "GetInsProvinceListOp.h"
#import "GetInsuranceOrderListOp.h"
#import "GetInsuranceOrderDetailsOp.h"
#import "CancelInsOrderOp.h"

@implementation InsuranceStore

- (void)reloadForUserChanged:(JTUser *)user
{
    self.simpleCars = nil;
    self.insOrders = nil;
}

- (void)dealloc
{
    
}
#pragma mark - Action
- (CKEvent *)getInsSimpleCars
{
    //获取保险支持的省份
    RACSignal *provSig = [[self getInsProvinces:NO] send];
    //获取保险车辆信息
    @weakify(self);
    RACSignal *carSig = [[[[GetInsCarListOp operation] rac_postRequest] map:^id(GetInsCarListOp *op) {
        @strongify(self);
        JTQueue *cars = [[JTQueue alloc] init];
        for (InsSimpleCar *car in op.rsp_carinfolist) {
            [cars addObject:car forKey:car.licenseno];
        }
        self.simpleCars = cars;
        self.xmddHelpTip = op.rsp_xmddhelptip;
        return op.rsp_carinfolist;
    }] replayLast];
    CKEvent *event = [[RACSignal combineLatest:@[provSig, carSig]] eventWithName:kEvtGetInsSimpleCars];
    return [self inlineEvent:event forDomain:@"simpleCars"];
}

- (CKEvent *)getInsProvinces:(BOOL)force
{
    if (!force && ![self needUpdateTimetagForKey:kEvtInsProvinces]) {
        return [[RACSignal return:self.insProvinces] eventWithName:kEvtInsProvinces];
    }
    @weakify(self);
    CKEvent *event = [[[[[GetInsProvinceListOp operation] rac_postRequest] map:^id(GetInsProvinceListOp *op) {
        @strongify(self);
        JTQueue *areas = [[JTQueue alloc] init];
        for (Area *a in op.rsp_provinces) {
            [areas addObject:a forKey:a.aid];
        }
        self.insProvinces = areas;
        [self updateTimetagForKey:kEvtInsProvinces];
        return op.rsp_provinces;
    }] replayLast] eventWithName:kEvtInsProvinces];
    return [self inlineEvent:event forDomain:@"insProvinces"];
}

- (CKEvent *)updateSimpleCar:(InsSimpleCar *)car
{
    [self.simpleCars addObject:car forKey:car.licenseno];
    return [self inlineEvent:[CKEvent eventWithName:kEvtUpdateInsSimpleCar signal:[RACSignal return:car]]];
}

///获取所有的保险订单列表
- (CKEvent *)getAllInsOrders
{
    @weakify(self);
    CKEvent *event = [[[[[GetInsuranceOrderListOp operation] rac_postRequest] map:^id(GetInsuranceOrderListOp *rspOp) {
        @strongify(self);
        JTQueue *cache = [[JTQueue alloc] init];
        for (HKInsuranceOrder *order in rspOp.rsp_orders) {
            [cache addObject:order forKey:order.orderid];
        }
        self.insOrders = cache;
        return rspOp.rsp_orders;
    }] replayLast] eventWithName:kEvtGetInsOrders];
    return [self inlineEvent:event forDomain:@"insOrders"];
}

///根据id获取指定的保险订单
- (CKEvent *)getInsOrderByID:(NSNumber *)orderID
{
    GetInsuranceOrderDetailsOp * op = [GetInsuranceOrderDetailsOp operation];
    op.req_orderid = orderID;
    @weakify(self);
    CKEvent *event = [[[[op rac_postRequest] map:^id(GetInsuranceOrderDetailsOp *op) {
        
        @strongify(self);
        [self.insOrders addObject:op.rsp_order forKey:op.rsp_order.orderid];
        return op.rsp_order;
    }] replayLast] eventWithName:kEvtGetInsOrder object:orderID];
    return [self inlineEvent:event forDomainList:@[@"insOrders", @"insOrder"]];
}

///取消指定的待支付保险订单
- (CKEvent *)cancelInsOrderByID:(NSNumber *)orderID
{
    CancelInsOrderOp *op = [CancelInsOrderOp operation];
    op.req_insorderid = orderID;
    @weakify(self);
    CKEvent *event = [[[[op rac_postRequest] map:^id(CancelInsOrderOp *op) {
        
        @strongify(self);
        [self.insOrders removeObjectForKey:orderID];
        return @(op.rsp_code);
    }] replayLast] eventWithName:kEvtCancelInsOrder object:orderID];
    return [self inlineEvent:event forDomain:@"insOrders"];
}


@end
