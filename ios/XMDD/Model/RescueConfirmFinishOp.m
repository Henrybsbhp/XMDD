//
//  RescueConfirmFinishOp.m
//  XMDD
//
//  Created by St.Jimmy on 21/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "RescueConfirmFinishOp.h"

@implementation RescueConfirmFinishOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/rescue/confirm/finshrescue";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_applyID forName:@"applyid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    return self;
}

@end
