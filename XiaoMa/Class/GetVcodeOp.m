//
//  GetVcodeOp.m
//  XiaoMa
//
//  Created by jt on 15-4-13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetVcodeOp.h"

@implementation GetVcodeOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/vcode/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_phone forName:@"phone"];
    [params addParam:self.req_token forName:@"token"];
    [params addParam:@(self.req_type) forName:@"type"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (id)returnSimulateResponse
{
    return @{@"rc":@0};
}

@end
