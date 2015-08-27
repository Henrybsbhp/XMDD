//
//  GetUserCouponOp2.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserCouponV2Op.h"

@implementation GetUserCouponV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resource/coupon/v2/get/by-page";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.used) forName:@"used"];
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
