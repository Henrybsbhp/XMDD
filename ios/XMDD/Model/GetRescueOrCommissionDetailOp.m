//
//  GetRescueOrCommissionDetail.m
//  XMDD
//
//  Created by St.Jimmy on 20/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetRescueOrCommissionDetailOp.h"

@implementation GetRescueOrCommissionDetailOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/rescue/detail";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.rsq_applyID forName:@"applyid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj[@"rescuedetail"];
    self.rsp_applyTime = [dict numberParamForName:@"applytime"];
    self.rsp_serviceName = [dict stringParamForName:@"servicename"];
    self.rsp_licenseNumber = [dict stringParamForName:@"licencenumber"];
    self.rsp_rescueStatus = [dict integerParamForName:@"rescuestatus"];
    self.rsp_commentStatus = [dict integerParamForName:@"commentstatus"];
    self.rsp_applyID = [dict integerParamForName:@"applyid"];
    self.rsp_type = [dict integerParamForName:@"type"];
    self.rsp_appointTime = [dict numberParamForName:@"appointtime"];
    self.rsp_pay = [dict floatParamForName:@"pay"];
    
    return self;
}

@end
