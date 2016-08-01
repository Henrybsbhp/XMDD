//
//  GetCouponByTypeNewV2Op.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/27.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetCouponByTypeNewV2Op.h"

@implementation GetCouponByTypeNewV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resources/coupon/v2/get/by-type";
    
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

- (NSString *)description
{
    return @"根据券类型查看所有可用优惠券";
}
@end
