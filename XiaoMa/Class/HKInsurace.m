//
//  HKInsurace.m
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKInsurace.h"

@implementation SubInsurace


@end

@implementation HKInsurace

+ (instancetype)insuraceWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKInsurace * insurace = [[HKInsurace alloc] init];
    insurace.premium= [rsp floatParamForName:@"premium"];
    NSArray * coverages = rsp[@"coverages"];
    NSMutableArray * tarray = [NSMutableArray array];
    for (NSDictionary * dict in coverages)
    {
        SubInsurace * subIns = [[SubInsurace alloc] init];
        subIns.coveragerName = dict[@"coverage"];
        subIns.fee = [rsp floatParamForName:@"fee"];
        subIns.sum = [rsp floatParamForName:@"sum"];
        [tarray addObject:subIns];
    }
    insurace.subInsuraceArray = [NSArray arrayWithArray:tarray];
    return insurace;
}

@end
