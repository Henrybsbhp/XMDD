//
//  GetRescueApplyHostCarOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescueApplyHostCarOp.h"

@implementation GetRescueApplyHostCarOp
- (RACSignal *)rac_postRequest
{
    self.req_method = @"/rescue/apply/hostcar";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.licenseNumber forKey:@"licensenumber"];
    [params safetySetObject:self.appointTime forKey:@"appointtime"];
    
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
    return @"申请协办";
}
@end
