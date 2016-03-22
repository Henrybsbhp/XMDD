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
    [params addParam:self.req_cardid forName:@"cardid"];
    [params addParam:self.req_claimid forName:@"claimid"];
    [params addParam:self.req_agreement forName:@"agreement"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}



@end
