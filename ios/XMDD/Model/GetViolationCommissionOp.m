//
//  GetViolationCommissionOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetViolationCommissionOp.h"

@implementation GetViolationCommissionOp


- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_licenceNumber forName:@"licencenumber"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_lists = rspObj[@"lists"];
    self.rsp_tip = rspObj[@"tip"];
    return self;
}



- (NSString *)description
{
    return @"获取用户可代办的违章记录";
}

@end
