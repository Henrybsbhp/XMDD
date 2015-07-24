//
//  BindDeviceToken2Op.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BindDeviceToken2Op.h"

@implementation BindDeviceToken2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/device/add";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_deviceID forName:@"deviceid"];
    [params addParam:self.req_deviceToken forName:@"devicetoken"];
    [params addParam:self.req_appversion forName:@"appversion"];
    [params addParam:self.req_osversion forName:@"osversion"];
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_district forName:@"district"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

@end
