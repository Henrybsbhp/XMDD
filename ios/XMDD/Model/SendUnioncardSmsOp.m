//
//  SendUnioncardSmsOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "SendUnioncardSmsOp.h"

@implementation SendUnioncardSmsOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/unioncard/sms/send";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_tokenid forName:@"tokenid"];
    [params addParam:self.req_tradeno forName:@"tradeno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
