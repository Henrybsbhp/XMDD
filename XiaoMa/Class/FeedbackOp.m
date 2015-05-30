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


@end
