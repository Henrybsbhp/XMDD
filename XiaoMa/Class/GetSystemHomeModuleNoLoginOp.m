//
//  GetSystemHomeModuleNoLoginOp.m
//  XiaoMa
//
//  Created by fuqi on 16/4/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetSystemHomeModuleNoLoginOp.h"

@implementation GetSystemHomeModuleNoLoginOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/home/nologin/module/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.appid) forName:@"os"];
    [params addParam:self.version forName:@"version"];
    [params addParam:self.province forName:@"province"];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.district forName:@"district"];
    
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
