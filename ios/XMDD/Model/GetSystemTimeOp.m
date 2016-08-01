//
//  getSystemTimeOp.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetSystemTimeOp.h"

@implementation GetSystemTimeOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/system/time/get";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_systime = rspObj[@"systime"];
    return self;
}

- (NSString *)description
{
    return @"获取系统时间，用于图片水印";
}
@end
