//
//  GainCouponPkgOp.m
//  XiaoMa
//
//  Created by jt on 15-5-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GainCouponPkgOp.h"

@implementation GainCouponPkgOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/coupon/queue/gain";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.pkgCode forName:@"pkgcode"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSString *)description
{
    return @"领取礼包";
}
@end
