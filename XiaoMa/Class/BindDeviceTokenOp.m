//
//  BindDeviceToken.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BindDeviceTokenOp.h"

@implementation BindDeviceTokenOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/devicetoken/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_deviceID forName:@"deviceid"];
    [params addParam:self.req_deviceToken forName:@"devicetoken"];
    [params addParam:self.req_appversion forName:@"appversion"];
    [params addParam:self.req_osversion forName:@"osversion"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
