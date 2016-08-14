//
//  GetViolationCommissionStateOp.m
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetViolationCommissionStateOp.h"

@implementation GetViolationCommissionStateOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/apply/detail/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.recordID forName:@"recordid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.vcSateModel = [ViolationCommissionStateModel listWithJSONResponse:rspObj];
    return self;
}

@end
