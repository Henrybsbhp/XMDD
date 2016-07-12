//
//  GetUserResourcesGaschargeOp.m
//  XiaoMa
//
//  Created by jt on 15/12/16.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "GetUserResourcesGaschargeOp.h"
#import "HKCoupon.h"

@implementation GetUserResourcesGaschargeOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resources/gascharge/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.req_fqjyflag) forName:@"fqjyflag"];
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
        self.rsp_couponArray = tArray;
    }
    else
    {
        NSAssert(NO, @"rac_postRequest parse error~~");
    }
    return self;
}


- (NSString *)description
{
    return @"查询用户加油可用的优惠券";
}
@end
