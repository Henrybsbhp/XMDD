//
//  ConfirmClaimOp.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ConfirmClaimOp.h"

@implementation ConfirmClaimOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/claim/confirm";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_bankcardno forName:@"bankcardno"];
    [params addParam:self.req_claimid forName:@"claimid"];
    [params addParam:self.req_agreement forName:@"agreement"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSString *)description
{
    return @"获取已经有的理赔银行卡列表";
}

@end
