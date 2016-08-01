//
//  GetSystemHomeModuleOp.m
//  XiaoMa
//
//  Created by fuqi on 16/4/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetSystemHomeModuleOp.h"

@implementation GetSystemHomeModuleOp

- (instancetype)init
{
    self  = [super init];
    if (self)
    {
        NSString * version = gAppMgr.clientInfo.clientVersion;
        self.appid = IOSAPPID;
        self.version = version;
    }
    return self;
}

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/home/module/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.appid) forName:@"os"];
    [params addParam:self.version forName:@"version"];
    [params addParam:self.province forName:@"province"];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.district forName:@"district"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.homeModel = [HomePicModel homeWithJSONResponse:rspObj];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


- (NSString *)description
{
    return @"获取APP首页模块配置信息（登录）";
}
@end
