//
//  GetTokenOp.m
//  XiaoMa
//
//  Created by jt on 15-4-13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetTokenOp.h"

@implementation GetTokenOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/token/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_phone forName:@"phone"];

    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_token = dict[@"token"];
    self.rsp_expires = dict[@"expires"];
    return self;
}

- (id)returnSimulateResponse
{
    return @{@"rc":@0,
             @"token":@"123456789012",
             @"expires":@(60*60*24*30)};
}

@end
