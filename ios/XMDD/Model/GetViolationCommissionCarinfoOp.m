//
//  GetViolationCommissionCarinfoOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetViolationCommissionCarinfoOp.h"

@implementation GetViolationCommissionCarinfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/carinfo/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_usercarid forName:@"usercarid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_licenseurl = rspObj[@"licenseurl"];
    self.rsp_licensecopyurl = rspObj[@"licensecopyurl"];
    self.rsp_carid = rspObj[@"carid"];
    return self;
}

- (NSString *)description
{
    return @"获取用户违章代办上传过的车辆证件照信息";
}

@end
