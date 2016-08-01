//
//  GetUnbindBankcardVcodeOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUnbindBankcardVcodeOp.h"

@implementation GetUnbindBankcardVcodeOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/vcode/unbind/get";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"获取验证码失败" code:-1 userInfo:nil];
    }
    return error;
}

- (NSString *)description
{
    return @"解绑时获取验证码";
}

@end
