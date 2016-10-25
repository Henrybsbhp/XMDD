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
    self.req_method = @"/user/violation/commission/apply";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_usercarid forName:@"usercarid"];
    [params addParam:self.req_licencenumber forName:@"licencenumber"];
    [params addParam:self.req_dates forName:@"dates"];
    if (self.req_idno.length)
    {
        [params addParam:self.req_idno forName:@"idno"];
    }
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_tip = [rspObj stringParamForName:@"tip"];
    }
    return self;
}

- (NSString *)description
{
    return @"用户违章代办申请";
}

@end
