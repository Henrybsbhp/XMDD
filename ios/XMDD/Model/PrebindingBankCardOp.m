//
//  PrebindingBankCardOp.m
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "PrebindingBankCardOp.h"

@implementation PrebindingBankCardOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/bankcard/prebind";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.cardNo forName:@"cardno"];
    [params addParam:self.tradeNo forName:@"tradeno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.bindURL = rspObj[@"bindurl"];
    
    return self;
}

@end
