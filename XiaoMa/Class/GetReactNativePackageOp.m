//
//  GetReactNativePackageOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetReactNativePackageOp.h"

@implementation GetReactNativePackageOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/rct/server/rctpkg/get/by-version";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_version forName:@"version"];
    [params addParam:self.req_appversion forName:@"appversion"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.baseManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_version = dict[@"version"];
    self.rsp_minappversion = dict[@"min-app-version"];
    self.rsp_desc = dict[@"desc"];
    self.rsp_patchurl = dict[@"patch"];
    
    return self;
}

@end
