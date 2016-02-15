//
//  GainUserAwardOp.m
//  XiaoMa
//
//  Created by jt on 15-6-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GainUserAwardOp.h"

@implementation GainUserAwardOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/award/gain";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_district forName:@"district"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_amount = [rspObj integerParamForName:@"amount"];
        self.rsp_couponId = rspObj[@"cid"];
        self.rsp_tip = rspObj[@"tip"];
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
