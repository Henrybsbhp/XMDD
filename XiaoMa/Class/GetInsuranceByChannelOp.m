//
//  BuyInsuranceByChannelOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetInsuranceByChannelOp.h"

@implementation GetInsuranceByChannelOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/get/by-channel";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_channel forName:@"channel"];
    [params addParam:self.req_licencenumber forName:@"licencenumber"];
    [params addParam:self.req_idnumber forName:@"idnumber"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_policyholder = dict[@"policyholder"];
    self.rsp_inscomp = dict[@"inscomp"];
    self.rsp_idnumber = dict[@"idnumber"];
    self.rsp_licencenumber = dict[@"licencenumber"];
    self.rsp_insperiod = dict[@"insperiod"];
    self.rsp_contactnumber = dict[@"contactnumber"];
    self.rsp_orderid = dict[@"orderid"];
    self.rsp_status = dict[@"status"];
    self.rsp_totalpay = dict[@"totalpay"];
    self.rsp_policy = [HKInsurance insuranceWithJSONResponse:dict[@"policy"]];
    return self;
    
}


@end
