//
//  GetUserCouponPkg.m
//  XiaoMa
//
//  Created by jt on 15-5-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserCouponPkgOp.h"
#import "HKCouponPkg.h"

@implementation GetUserCouponPkgOp


- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/couponpkg/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * pkgs = (NSArray *)rspObj[@"packages"];
        NSMutableArray * tArray = [NSMutableArray array];
        for (NSDictionary * dict in pkgs)
        {
            HKCouponPkg * pkg = [HKCouponPkg couponPkgWithJSONResponse:dict];
            [tArray addObject:pkg];
        }
        self.rsp_pkgArray = tArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
