//
//  GetCalculateBaseInfoOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetCalculateBaseInfoOp.h"

@implementation GetCalculateBaseInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/premium/baseinfo/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.insuranceList = rspObj[@"insurancelist"];
    self.couponList = rspObj[@"couponlist"];
    
    return self;
}

@end
