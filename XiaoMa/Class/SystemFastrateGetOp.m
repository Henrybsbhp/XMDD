//
//  SystemFastrateGetOp.m
//  XiaoMa
//
//  Created by jt on 15/9/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "SystemFastrateGetOp.h"

@implementation SystemFastrateGetOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/fastrate/get";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_commentlist = dict[@"commentlist"];
    return self;
}

- (NSString *)description
{
    return @"获取各星级下面的简易评价内容";
}
@end
