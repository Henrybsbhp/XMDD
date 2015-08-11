//
//  UnbindBankcardOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UnbindBankcardOp.h"

@implementation UnbindBankcardOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/bankcard/unbind";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_vcode forName:@"vcode"];
    [params addParam:self.req_cardid forName:@"bid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"解绑失败,请重试" code:0 userInfo:nil];
    }
    return error;
}


@end
