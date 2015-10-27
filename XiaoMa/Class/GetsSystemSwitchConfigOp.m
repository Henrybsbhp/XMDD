//
//  GetsSystemSwitchConfigOp.m
//  XiaoMa
//
//  Created by jt on 15/10/23.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetsSystemSwitchConfigOp.h"

@implementation GetsSystemSwitchConfigOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/switch/config/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.appid) forName:@"appcode"];
    [params addParam:self.version forName:@"version"];
    [params addParam:self.os forName:@"os"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}


- (instancetype)parseResponseObject:(id)rspObj
{
    if([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * dict = (NSDictionary *)rspObj;
        self.rsp_configurations = rspObj;
    }
    else
    {
        NSAssert(NO, @"GetsSystemSwitchConfigOp parse error~~");
    }
    return self;
}

@end
