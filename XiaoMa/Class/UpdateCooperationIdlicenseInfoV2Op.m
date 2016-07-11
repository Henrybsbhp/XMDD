//
//  UpdateCooperationIdlicenseInfoV2Op.m
//  XiaoMa
//
//  Created by fuqi on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UpdateCooperationIdlicenseInfoV2Op.h"

@implementation UpdateCooperationIdlicenseInfoV2Op


- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/idlicense/info/update/v2";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_idurl forKey:@"idurl"];
    [params safetySetObject:self.req_licenseurl forKey:@"licenseurl"];
    [params safetySetObject:self.req_firstinscomp forKey:@"firstinscomp"];
    [params safetySetObject:self.req_secinscomp forKey:@"secinscomp"];
    [params safetySetObject:self.req_memberid ?: @(0) forKey:@"memberid"];
    [params safetySetObject:@(self.req_isbuyfroceins) forKey:@"isbuyfroceins"];
    [params safetySetObject:self.req_licensenumber forKey:@"licensenumber"];
    [params safetySetObject:self.req_licensenumber ?: @(0) forKey:@"usercarid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    
    return self;
}

- (NSString *)description
{
    return @"身份证和行驶证信息更新到团中v2";
}

@end
