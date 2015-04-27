//
//  GetInsuranceCalculatorOp.m
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetInsuranceCalculatorOp.h"
#import "NSDate+DateForText.h"
#import "HKInsurance.h"

@implementation GetInsuranceCalculatorOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/calculator/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.licencenumber forName:@"licencenumber"];
    [params addParam:@(self.registered) forName:@"registered"];
    [params addParam:@(self.purchaseprice) forName:@"purchaseprice"];
    [params addParam:[self.purchasedate dateFormatForDT8]  forName:@"purchasedate"];
    [params addParam:self.phone forName:@"phone"];
    
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
            HKInsurance * ins = [HKInsurance insuranceWithJSONResponse:dict2[@"policy"]];
            ins.insuranceName = dict2[@"name"];
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
