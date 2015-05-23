//
//  HKCouponPkg.m
//  XiaoMa
//
//  Created by jt on 15-5-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKCouponPkg.h"
#import "HKCoupon.h"

@implementation HKCouponPkg

+ (instancetype)couponPkgWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    
    HKCouponPkg * pkg = [[HKCouponPkg alloc] init];
    pkg.pkgName = rsp[@"name"];
    NSArray * array = rsp[@"coupons"];
    NSMutableArray * t = [NSMutableArray array];
    for (NSDictionary * dict in array)
    {
        [t addObject:[HKCoupon couponWithJSONResponse:dict]];
    }
    pkg.couponsArray = [NSArray arrayWithArray:t];
    return pkg;
}


@end
