//
//  ApplyViolationCommissionOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ApplyViolationCommissionOp.h"

@implementation ApplyViolationCommissionOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/apply/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_usercarid forName:@"usercarid"];
    [params addParam:self.req_licencenumber forName:@"licencenumber"];
    [params addParam:self.req_dates forName:@"dates"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSString *)description
{
    return @"用户违章代办申请";
}

@end
