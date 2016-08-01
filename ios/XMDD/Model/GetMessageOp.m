//
//  GetMessageOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetMessageOp.h"

@implementation GetMessageOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/message/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.req_msgtime) forName:@"msgtime"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSArray *msgDictArray = dict[@"messages"];
    NSMutableArray *msgs = [NSMutableArray array];
    for (NSDictionary *msgdict in msgDictArray) {
        HKMessage *msg = [HKMessage messageWithJSONResponse:msgdict];
        [msgs addObject:msg];
    }
    self.rsp_msgs = msgs;

    return self;
}

- (NSString *)description
{
    return @"获取用户消息。每次返回10条消息";
}
@end
