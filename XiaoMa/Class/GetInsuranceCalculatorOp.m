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
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_licencenumber forName:@"licencenumber"];
    [params addParam:@(self.req_registered) forName:@"registered"];
    [params addParam:@(self.req_purchaseprice) forName:@"purchaseprice"];
    [params addParam:[self.req_purchasedate dateFormatForDT8]  forName:@"purchasedate"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * dict = (NSDictionary *)rspObj;
        self.rsp_calculatorID = dict[@"cid"];
        NSArray * quotes = dict[@"quotes"];
        NSMutableArray * tarray = [NSMutableArray array];
        for (NSDictionary *quoteDict in quotes)
        {
            HKInsurance * ins = [HKInsurance insuranceWithJSONResponse:quoteDict];
            ins.insuranceName = quoteDict[@"name"];
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
