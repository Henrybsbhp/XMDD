//
//  GetSystemHomePicOp.m
//  XiaoMa
//
//  Created by jt on 16/1/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetSystemHomePicOp.h"

@implementation GetSystemHomePicOp

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
    self.req_method = @"/system/index/pic/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.appid) forName:@"os"];
    [params addParam:self.version forName:@"version"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
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

@end
