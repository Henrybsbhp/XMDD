//
//  GetInsuranceDiscountOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetInsuranceDiscountOp.h"

@implementation GetInsuranceDiscountOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/get/discountrates";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *discountArray = [NSMutableArray array];
    for (NSDictionary *discountDict in dict[@"policys"]) {
        InsuranceDiscount * insuranceDis = [InsuranceDiscount insuranceDiscountWithJSONResponse:discountDict];
        [discountArray safetyAddObject:insuranceDis];
    }
    self.rsp_dicInsurance = discountArray;
    return self;
}

- (NSString *)description
{
    return @"获取险种对应的折扣率";
}
@end
