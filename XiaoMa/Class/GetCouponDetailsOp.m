//
//  GetCouponDetailsOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetCouponDetailsOp.h"

@implementation GetCouponDetailsOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resources/coupon/detail/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_cid forName:@"cid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}


- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    
    HKCoupon * coupon = [HKCoupon couponDetailsWithJSONResponse:dict[@"detail"]];
    self.rsp_couponDetails = coupon;
    
    return self;
}

@end
