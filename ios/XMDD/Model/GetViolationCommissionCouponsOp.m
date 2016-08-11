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
    self.rsp_coupons = rspObj[@"coupons"];
    return self;
}


- (NSString *)description
{
    return @"获取用户违章代办的可用优惠券";
}

@end
