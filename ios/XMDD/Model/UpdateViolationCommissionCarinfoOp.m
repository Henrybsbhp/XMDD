//
//  UpdateViolationCommissionCarinfoOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UpdateViolationCommissionCarinfoOp.h"

@implementation UpdateViolationCommissionCarinfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/carinfo/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_carid forName:@"carid"];
    [params addParam:self.req_licenseurl forName:@"licenseurl"];
    [params addParam:self.req_licensecopyurl forName:@"licensecopyurl"];
    [params addParam:self.req_licencenumber forName:@"licencenumber"];
    [params addParam:self.req_usercarid forName:@"usercarid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSString *)description
{
    return @"完善违章代办车辆证件照信息";
}

@end
