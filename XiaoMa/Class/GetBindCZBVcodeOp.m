//
//  GetBindCZBVcodeOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetBindCZBVcodeOp.h"

@implementation GetBindCZBVcodeOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/czbcode/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_bankcardno forName:@"bankcardno"];
    [params addParam:self.req_phone forName:@"phone"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"验证码获取失败，请重新获取" code:-1 userInfo:nil];
    }
    return error;
}

- (NSString *)description
{
    return @"绑定浙商银行卡时获取验证码";
}
@end
