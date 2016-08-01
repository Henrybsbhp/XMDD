//
//  RescueCancelHostcarOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/29.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "RescueCancelHostcarOp.h"

@implementation RescueCancelHostcarOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/rescue/cancel/hostcar";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.applyId forKey:@"applyid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"申请失败, 请重试" code:error.code userInfo:error.userInfo];
    }
    return error;
}


- (NSString *)description
{
    return @"协办取消申请";
}

@end
