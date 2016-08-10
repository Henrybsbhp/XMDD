//
//  GetGasCardInfoOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/21/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetGasCardInfoOp.h"

@implementation GetGasCardInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/gas/querycard";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.gasCard forName:@"gascard"];
    [params addParam:self.cardType forName:@"cardtype"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.username = rspObj[@"username"];
    
    return self;
}

@end
