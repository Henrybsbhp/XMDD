//
//  InsuranceOrderPaidSuccessOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "OrderPaidSuccessOp.h"

@implementation OrderPaidSuccessOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/order/result/notify";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.req_notifytype) forName:@"notifytype"];
    [params addParam:self.req_tradeno forName:@"tradeno"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}


- (NSString *)description
{
    return @"支付成功的通知接口";
}
@end
