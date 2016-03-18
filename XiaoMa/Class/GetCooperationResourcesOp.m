//
//  GetCooperationResourcesOp.m
//  XiaoMa
//
//  Created by jt on 16/3/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetCooperationResourcesOp.h"


@implementation GetCooperationResourcesOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/resources/cooperation/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSArray * couponlist = rspObj[@"coupons"];
    NSMutableArray * array = [NSMutableArray array];
    for (NSDictionary * dict  in couponlist)
    {
        HKCoupon * coupon = [HKCoupon couponWithJSONResponse:dict];
        [array safetyAddObject:coupon];
    }
    self.rsp_couponArray = [NSArray arrayWithArray:array];
    self.rsp_maxcouponamt = [rspObj floatParamForName:@"maxcouponamt"];
    return self;
}

@end
