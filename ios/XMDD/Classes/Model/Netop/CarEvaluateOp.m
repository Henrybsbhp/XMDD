//
//  CarEvaluateOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/16.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "CarEvaluateOp.h"

@implementation CarEvaluateOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/thirdpart/car/evaluate";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString * milesStr = [NSString stringWithFormat:@"%.2f", self.req_mile];
    [params addParam:@([milesStr floatValue]) forName:@"mile"];
    [params addParam:self.req_modelid forName:@"modelid"];
    [params addParam:[self.req_buydate dateFormatForDT8] forName:@"buydate"];
    [params addParam:self.req_carid forName:@"carid"];
    [params addParam:self.req_cityid forName:@"cityid"];
    [params addParam:self.req_licenseno forName:@"licenseno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_normalPrice = [rspObj floatParamForName:@"normalprice"];
        self.rsp_betterPrice = [rspObj floatParamForName:@"betterprice"];
        self.rsp_bestPrice = [rspObj floatParamForName:@"bestprice"];
        self.rsp_url = [rspObj stringParamForName:@"url"];
        self.rsp_tip = [rspObj stringParamForName:@"tip"];
        self.rsp_carid = [rspObj numberParamForName:@"carid"];
        self.rsp_sharecode = [rspObj stringParamForName:@"sharecode"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


- (NSString *)description
{
    return @"二手车估值";
}
@end
