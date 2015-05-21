//
//  GetAutomobileModelOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetAutomobileModelOp.h"

@implementation GetAutomobileModelOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/series/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_brandid forName:@"bid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_seriesList = dict[@"series"];
    return self;
}

@end
