//
//  GetSystemJSPatchOp.m
//  XiaoMa
//
//  Created by jt on 16/1/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetSystemJSPatchOp.h"

@implementation GetSystemJSPatchOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/jspatch/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.phoneNumber forName:@"phone"];
    [params addParam:self.version forName:@"version"];
    [params addParam:self.province forName:@"province"];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.district forName:@"district"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dic = rspObj;
    self.rsp_jspatchUrl = dic[@"url"];
    return self;
}

@end
