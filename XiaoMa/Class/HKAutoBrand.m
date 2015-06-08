//
//  HKAutoBrand.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKAutoBrand.h"

@implementation HKAutoBrand

+ (instancetype)autoBrandWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKAutoBrand *brand = [HKAutoBrand new];
    brand.brandid = rsp[@"bid"];
    brand.name = rsp[@"name"];
    brand.tag = rsp[@"tag"];
    brand.logo = rsp[@"logo"];
    brand.timetag = [rsp[@"timetag"] longLongValue];
    
    return brand;
}

@end
