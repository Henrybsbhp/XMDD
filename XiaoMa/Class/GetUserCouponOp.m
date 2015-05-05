//
//  GetUserCouponOp.m
//  XiaoMa
//
//  Created by jt on 15-4-30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserCouponOp.h"
#import "HKCoupon.h"

@implementation GetUserCouponOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resource/coupon/get/by-page";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.used) forName:@"user"];
    [params addParam:self.pageno ? @(self.pageno):@(1) forName:@"pageno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}


- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * shops = (NSArray *)rspObj[@"coupons"];
        NSMutableArray * tArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in shops)
        {
            HKCoupon * coupon = [HKCoupon couponWithJSONResponse:dict];
            [tArray addObject:coupon];
        }
        self.rsp_couponsArray = tArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
