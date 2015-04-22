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
    self.req_method = @"getUpdateInfo";
    
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
    }
    else
    {
        NSAssert(NO, @"GetUpdateInfoOp parse error~~");
    }
    return self;
    
}


@end
