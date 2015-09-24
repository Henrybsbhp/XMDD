//
//  CheckUserAwardOp.m
//  XiaoMa
//
//  Created by jt on 15-6-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CheckUserAwardOp.h"

@implementation CheckUserAwardOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/award/check";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_leftday = [rspObj integerParamForName:@"leftday"];
        self.rsp_amount = [rspObj integerParamForName:@"amount"];
        self.rsp_tip = rspObj[@"tip"];
        self.rsp_total = [rspObj integerParamForName:@"total"];
        self.rsp_isused = [rspObj boolParamForName:@"isused"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"检查失败，请重试" code:error.code userInfo:error.userInfo];
    }
    return error;
}

@end
