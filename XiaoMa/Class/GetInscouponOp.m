//
//  GetInscouponOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetInscouponOp.h"
#import "HKCoupon.h"

@implementation GetInscouponOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/inscoupon/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.orderid forName:@"orderid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * coupons = (NSArray *)rspObj[@"coupons"];
        NSMutableArray * tArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in coupons)
        {
            HKCoupon * coupon = [HKCoupon couponWithJSONResponse:dict];
            [tArray addObject:coupon];
        }
        self.rsp_inscouponsArray = tArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


- (NSString *)description
{
    return @"获取当前用户的可用保险优惠券";
}

@end
