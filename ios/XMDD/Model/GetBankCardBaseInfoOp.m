//
//  GetBankCardBaseInfoOp.m
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetBankCardBaseInfoOp.h"

@implementation GetBankCardBaseInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/bankcard/baseinfo/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.cardNo forName:@"cardno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.issueBank = rspObj[@"issuebank"];
    self.cardType = rspObj[@"cardtype"];
    self.bankLogo = rspObj[@"banklogo"];
    
    return self;
}

@end
