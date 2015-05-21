//
//  GetAutomobileBrandOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetAutomobileBrandOp.h"

@implementation GetAutomobileBrandOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/brand/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_timetag forName:@"timetag"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_brands = dict[@"brands"];
    
    return self;
}

@end
