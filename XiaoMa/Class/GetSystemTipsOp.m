//
//  GetSystemTipsOp.m
//  XiaoMa
//
//  Created by jt on 15-4-20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetSystemTipsOp.h"

@implementation GetSystemTipsOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/tips/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.province forName:@"province"];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.district forName:@"district"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_restriction = rspObj[@"restriction"];
        self.rsp_temperature = rspObj[@"temperature"];
        self.rsp_temperaturetip = rspObj[@"temperaturetip"];
        self.rsp_temperaturepic = rspObj[@"temperaturepic"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
