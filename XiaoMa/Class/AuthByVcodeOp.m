//
//  AuthByVcodeOp.m
//  XiaoMa
//
//  Created by jt on 15-4-13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AuthByVcodeOp.h"

@implementation AuthByVcodeOp

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/auth/by-vcode";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_deviceID forKey:@"deviceid"];
    [params safetySetObject:self.req_deviceModel forKey:@"devicemodel"];
    [params safetySetObject:self.req_appVersion forKey:@"version"];
    [params safetySetObject:self.req_blackBox forKey:@"blackbox"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (id)returnSimulateResponse
{
    return @{@"rc":@0};
}


@end
