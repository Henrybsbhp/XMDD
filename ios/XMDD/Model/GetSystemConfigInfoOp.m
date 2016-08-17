//
//  GetSystemConfigInfoOp.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetSystemConfigInfoOp.h"

@implementation GetSystemConfigInfoOp
- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/config/info";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_area forName:@"area"];
    [params addParam:@(self.req_type) forName:@"type"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_configInfo = dict[@"configinfo"];
    self.dict = dict;
    return self;
}

- (NSString *)maintenanceDesc {
    return self.rsp_configInfo[@"bydesc"];
}

@end
