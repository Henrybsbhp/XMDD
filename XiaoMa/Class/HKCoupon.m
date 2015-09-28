//
//  HKCoupon.m
//  XiaoMa
//
//  Created by jt on 15-4-17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKCoupon.h"
#import "NSDate+DateForText.h"

@implementation HKCoupon

+ (instancetype)couponWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKCoupon * coupon = [[HKCoupon alloc] init];
    coupon.couponId = rsp[@"cid"];
    coupon.couponName = rsp[@"name"];
    coupon.couponAmount = [rsp floatParamForName:@"amount"];
    coupon.couponDescription = rsp[@"description"];
    coupon.used = [rsp intParamForName:@"used"] == 1;
    coupon.valid = [rsp intParamForName:@"valid"] == 1;
    coupon.isshareble = [rsp intParamForName:@"isshareble"];
    coupon.validsince = [NSDate dateWithD8Text:[NSString stringWithFormat:@"%@",rsp[@"validsince"]]];
    coupon.validthrough = [NSDate dateWithD8Text:[NSString stringWithFormat:@"%@",rsp[@"validthrough"]]];
    coupon.conponType = (CouponType)[rsp integerParamForName:@"type"];
    coupon.rgbColor = [rsp stringParamForName:@"rgb"];
    coupon.logo = [rsp stringParamForName:@"logo"];
    coupon.subname = [rsp stringParamForName:@"subname"];
    return coupon;
}

+ (instancetype)couponDetailsWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKCoupon * coupon = [[HKCoupon alloc] init];
    coupon.couponName = rsp[@"name"];
    coupon.couponDescription = rsp[@"description"];
    coupon.validsince = [NSDate dateWithD8Text:[NSString stringWithFormat:@"%@",rsp[@"validsince"]]];
    coupon.validthrough = [NSDate dateWithD8Text:[NSString stringWithFormat:@"%@",rsp[@"validthrough"]]];
    coupon.rgbColor = [rsp stringParamForName:@"rgb"];
    coupon.logo = [rsp stringParamForName:@"logo"];
    coupon.subname = rsp[@"subname"];
    coupon.useguide = rsp[@"useguide"];

    return coupon;
}

@end
