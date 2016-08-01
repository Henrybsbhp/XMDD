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
    self.req_method = @"/rct/servlet/rctpkg/get/by-version";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_rctversion forName:@"rctversion"];
    [params addParam:self.req_appversion forName:@"appversion"];
    [params addParam:self.req_timetag forName:@"timetag"];
    [params addParam:self.req_projectname forName:@"projectname"];
    [params addParam:self.req_buildtype forName:@"buildtype"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.baseManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_rctversion = dict[@"rctversion"];
    self.rsp_minappversion = dict[@"appversion"];
    self.rsp_patchurl = dict[@"patchurl"];
    self.rsp_patchsign = dict[@"patchsign"];
    self.rsp_jssummary = dict[@"jssummary"];
    return self;
}

@end
