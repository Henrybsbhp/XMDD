//
//  GetUserResourcesOp.m
//  XiaoMa
//
//  Created by jt on 15-4-15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserResourcesOp.h"
#import "HKCoupon.h"

@implementation GetUserResourcesOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resources/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
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
        self.rsp_coupons = tArray;
        self.rsp_bankIntegral = [rspObj integerParamForName:@"bankcredits"];
        self.rsp_freewashes = [rspObj integerParamForName:@"freewashes"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
