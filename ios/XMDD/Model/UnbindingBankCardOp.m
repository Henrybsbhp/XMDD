//
//  UnbindingBankCardOp.m
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "UnbindingBankCardOp.h"

@implementation UnbindingBankCardOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/unioncard/unbind";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.tokenID forName:@"tokenid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    return self;
}

@end
