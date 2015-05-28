//
//  GetUserCouponByType.m
//  XiaoMa
//
//  Created by jt on 15-5-28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserCouponByTypeOp.h"

@implementation GetUserCouponByTypeOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resources/coupon/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.type) forName:@"coupontype"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
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
