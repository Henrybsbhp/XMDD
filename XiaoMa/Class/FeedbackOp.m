//
//  FeedbackOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "FeedbackOp.h"

@implementation FeedbackOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/feedback";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_contactinfo forKey:@"contactinfo"];
    [params safetySetObject:self.req_feedback forKey:@"feedback"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_prompt = @"反馈成功，您的意见是我们宝贵的财富";
    return self;
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"反馈失败，请稍后再试" code:error.code userInfo:error.userInfo];
    }
    return error;
}

@end
