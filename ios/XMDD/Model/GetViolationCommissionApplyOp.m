//
//  GetViolationCommissionApplyOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetViolationCommissionApplyOp.h"

@implementation GetViolationCommissionApplyOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/apply/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_lists = rspObj[@"lists"];
    self.rsp_tipslist = rspObj[@"tipslist"];
    return self;
}



- (NSString *)description
{
    return @"获取用户已申请过的违章代办记录";
}

@end
