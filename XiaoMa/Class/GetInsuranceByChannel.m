//
//  GetInsuranceByChannel.m
//  XiaoMa
//
//  Created by jt on 15-4-22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetInsuranceByChannel.h"

@implementation GetInsuranceByChannel

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/get/by-channel";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.channel forName:@"channel"];
    [params addParam:self.licencenumber forName:@"licencenumber"];
    [params addParam:self.idnumber forName:@"idnumber"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * dict = (NSDictionary *)rspObj;
        self.rsp_policyholder = [dict objectForKey:@"policyholder"];
        self.rsp_inscomp = [dict objectForKey:@"inscomp"];
        self.rsp_idnumber = [dict objectForKey:@"idnumber"];
        self.rsp_licencenumber = [dict objectForKey:@"licencenumber"];
        self.rsp_insperiod = [dict objectForKey:@"insperiod"];
        self.rsp_contactnumber = [dict objectForKey:@"contactnumber"];
        self.rsp_policy = [HKInsurance insuranceWithJSONResponse:[dict objectForKey:@"policy"]];
        self.rsp_orderid = [dict objectForKey:@"orderid"];
        self.rsp_status = [dict integerParamForName:@"orderid"];
        self.rsp_totalpay = [dict floatParamForName:@"orderid"];
    }
    else
    {
        NSAssert(NO, @"GetUpdateInfoOp parse error~~");
    }
    return self;
    
}


@end
