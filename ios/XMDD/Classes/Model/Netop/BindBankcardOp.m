//
//  BindBankcardOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BindBankcardOp.h"

@implementation BindBankcardOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/bankcard/bind";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_bankcardno forName:@"bankcardno"];
    [params addParam:self.req_phone forName:@"phone"];
    [params addParam:self.req_vcode forName:@"vcode"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1 || error.domain.length == 0) {
        error = [NSError errorWithDomain:@"绑定失败,请重新绑定" code:error.code userInfo:nil];
    }
    return error;
}

- (NSString *)description
{
    return @"绑定银行卡";
}

@end
