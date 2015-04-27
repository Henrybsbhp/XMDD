//
//  GetInsuranceCalculatorOp.m
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetInsuranceCalculatorOp.h"
#import "NSDate+DateForText.h"
#import "HKInsurace.h"

@implementation GetInsuranceCalculatorOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/calculator/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_licencenumber forName:@"licencenumber"];
    [params addParam:@(self.req_registered) forName:@"registered"];
    [params addParam:@(self.req_purchaseprice) forName:@"purchaseprice"];
    [params addParam:[self.req_purchasedate dateFormatForDT8]  forName:@"purchasedate"];
    [params addParam:self.req_phone forName:@"phone"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * dict = (NSDictionary *)rspObj;
        NSArray * quotes = dict[@"quotes"];
        NSMutableArray * tarray = [NSMutableArray array];
        for (NSObject * obj in quotes)
        {
            NSDictionary * dict2 = (NSDictionary *)obj;
            HKInsurace * ins = [HKInsurace insuraceWithJSONResponse:dict2[@"policy"]];
            ins.insuraceName = dict2[@"name"];
            [tarray addObject:ins];
        }
        self.rsp_insuraceArray = [NSArray arrayWithArray:tarray];
    }
    else
    {
        NSAssert(NO, @"GetUpdateInfoOp parse error~~");
    }
    return self;
    
}


@end
