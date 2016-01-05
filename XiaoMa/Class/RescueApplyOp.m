//
//  RescueApplyOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescueApplyOp.h"

@implementation RescueApplyOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/rescue/applyRescue";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.longitude forName:@"longitude"];
    [params addParam:self.latitude forName:@"latitude"];
    [params addParam:self.address forName:@"address"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -2003) {
        error = [NSError errorWithDomain:error.domain code:9999 userInfo:error.userInfo];
    }
    return error;
}

@end
