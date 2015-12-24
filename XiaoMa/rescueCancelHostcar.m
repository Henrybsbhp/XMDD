//
//  rescueCancelHostcar.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/22.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "rescueCancelHostcar.h"

@implementation rescueCancelHostcar
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

@end
