//
//  GetViolationCommissionCouponsOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetViolationCommissionCouponsOp.h"

@implementation GetViolationCommissionCouponsOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/coupons/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSDictionary * dict  in rspObj[@"coupons"])
    {
        HKCoupon * coupon = [HKCoupon couponWithJSONResponse:dict];
        [array safetyAddObject:coupon];
    }
    self.rsp_coupons = [NSArray arrayWithArray:array];
    return self;
}


- (NSString *)description
{
    return @"获取用户违章代办的可用优惠券";
}

@end
