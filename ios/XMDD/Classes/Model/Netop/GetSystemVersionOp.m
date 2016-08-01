//
//  GetSystemVersionOp.m
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetSystemVersionOp.h"

@implementation GetSystemVersionOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/version/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.appid) forName:@"appcode"];
    [params addParam:self.version forName:@"version"];
    [params addParam:self.os forName:@"os"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}


- (instancetype)parseResponseObject:(id)rspObj
{
    if([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * dict = (NSDictionary *)rspObj;
        self.rsp_version = [dict objectForKey:@"version"];
        self.rsp_link =  [dict objectForKey:@"link"];
        self.rsp_updateinfo = [dict objectForKey:@"updateinfo"];
        self.rsp_mandatory = [dict boolParamForName:@"mandatory"];
        self.rsp_prompt = @"当前已是最新版本";
    }
    else
    {
        NSAssert(NO, @"GetUpdateInfoOp parse error~~");
    }
    return self;
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"小马哥有点忙，过会儿试试吧" code:error.code userInfo:error.userInfo];
    }
    return error;
}


- (NSString *)description
{
    return @"获取app版本更新";
}


@end
