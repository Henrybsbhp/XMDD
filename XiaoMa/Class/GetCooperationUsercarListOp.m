//
//  GetCooperationUsercarListOp.m
//  XiaoMa
//
//  Created by fuqi on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetCooperationUsercarListOp.h"

@implementation GetCooperationUsercarListOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/usercar/list/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_carArray = rspObj[@"usercarlist"];
    return self;
}

@end
