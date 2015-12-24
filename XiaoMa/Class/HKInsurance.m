//
//  HKInsurace.m
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKInsurance.h"
#import "HKCoverage.h"

@implementation SubInsurance

@end

@implementation HKInsurance

+ (instancetype)insuranceWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKInsurance * insurance = [[HKInsurance alloc] init];
    insurance.premium= [rsp floatParamForName:@"totalfee"];
    NSArray * coverages = rsp[@"coverages"];
    NSMutableArray * tarray = [NSMutableArray array];
    for (NSDictionary * dict in coverages)
    {
        SubInsurance * subIns = [[SubInsurance alloc] init];
        subIns.coveragerName = dict[@"name"];
        subIns.coveragerValue = dict[@"value"];
        subIns.coveragerId = [dict numberParamForName:@"pid"];
        [tarray addObject:subIns];
    }
    insurance.subInsuranceArray = tarray;
    return insurance;
}

@end


@implementation InsuranceDiscount

+ (instancetype)insuranceDiscountWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    InsuranceDiscount * disIns = [[InsuranceDiscount alloc] init];
    disIns.pid = [rsp numberParamForName:@"pid"];
    disIns.discountrate = [rsp floatParamForName:@"discountrate"];
    return disIns;
}

@end

