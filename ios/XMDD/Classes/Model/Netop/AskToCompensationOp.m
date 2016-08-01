//
//  AskToCompensationOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 5/31/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "AskToCompensationOp.h"

@implementation AskToCompensationOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/claims/list/v2";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.claimList = dict[@"claimlist"];
    self.bankNoDesc = dict[@"banknodesc"];
    
    return self;
}

- (NSString *)description
{
    return @"理赔记录列表";
}

@end
