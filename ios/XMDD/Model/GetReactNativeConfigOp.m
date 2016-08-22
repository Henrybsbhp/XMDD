//
//  GetReactNativeConfigOp.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetReactNativeConfigOp.h"

@implementation GetReactNativeConfigOp

- (RACSignal *)rac_postRequest {
    if (self.req_security) {
        self.req_method = @"/system/reactnative/config/get";
    }
    else {
        self.req_method = @"/system/reactnative/config/nologin/get";
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_district forName:@"area"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:self.req_security];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_openflag = [dict integerParamForName:@"openflag"];
    return self;
}

@end
