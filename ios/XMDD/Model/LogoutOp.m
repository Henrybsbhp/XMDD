//
//  LogoutOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "LogoutOp.h"

@implementation LogoutOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/auth/logout";
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (BOOL)shouldHandleDefaultError
{
    return NO;
}

- (NSString *)description
{
    return @"退出登录";
}

@end
