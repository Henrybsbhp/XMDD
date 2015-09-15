//
//  GetCouponByTypeNewOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetCouponByTypeNewOp.h"

@implementation GetCouponByTypeNewOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resources/coupon/get/by-type";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.coupontype) forName:@"coupontype"];
    [params addParam:self.pageno ? @(self.pageno):@(1) forName:@"pageno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}


- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    
    NSArray * shops = dict[@"coupons"];
    NSMutableArray * tArray = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in shops)
    {
        HKCoupon * coupon = [HKCoupon couponWithJSONResponse:dict];
        [tArray addObject:coupon];
    }
    self.rsp_couponsArray = tArray;
    
    return self;
}

@end
