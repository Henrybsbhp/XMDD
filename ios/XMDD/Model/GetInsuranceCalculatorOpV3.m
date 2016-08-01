//
//  GetInsuranceCalculatorOpV3.m
//  XiaoMa
//
//  Created by jt on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "GetInsuranceCalculatorOpV3.h"

@implementation GetInsuranceCalculatorOpV3

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/calculator/v3/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_city forKey:@"city"];
    [params safetySetObject:self.req_licencenumber forKey:@"licencenumber"];
    [params safetySetObject:@(self.req_registered) forKey:@"registered"];
    [params safetySetObject:self.req_purchaseprice forKey:@"purchaseprice"];
    [params safetySetObject:[self.req_purchasedate dateFormatForDT8]  forKey:@"purchasedate"];
    
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
        NSAssert(NO, @"GetInsuranceCalculatorOpV3 parse error~~");
    }
    return self;
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"询价失败，请重试" code:error.code userInfo:error.userInfo];
    }
    return error;
}

- (NSString *)description
{
    return @"保险计算器（询价）";
}

@end
