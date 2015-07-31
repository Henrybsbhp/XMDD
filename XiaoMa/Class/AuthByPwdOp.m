//
//  AuthByPwdOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AuthByPwdOp.h"

@implementation AuthByPwdOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/auth/by-pwd";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_deviceID forKey:@"deviceid"];
    [params safetySetObject:self.req_deviceModel forKey:@"devicemodel"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"密码重置失败，请重试" code:error.code userInfo:error.userInfo];
    }
    return error;
}

@end
