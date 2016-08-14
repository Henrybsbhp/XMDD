//
//  CancelViolationCommissionOp.m
//  XMDD
//
//  Created by St.Jimmy on 8/9/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CancelViolationCommissionOp.h"

@implementation CancelViolationCommissionOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/apply/cancel";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.recordID forName:@"recordid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    return self;
}

@end
