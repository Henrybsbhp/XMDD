//
//  CheckoutUnioncardQuickpayOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CheckoutUnioncardQuickpayOp.h"

@implementation CheckoutUnioncardQuickpayOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/unioncard/quickpay/checkout";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_tokenid forName:@"tokenid"];
    [params addParam:self.req_tradeno forName:@"tradeno"];
    [params addParam:self.req_vcode forName:@"vcode"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}


@end
