//
//  GetVoiceVCodeOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetVoiceVCodeOp.h"

@implementation GetVoiceVCodeOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/vcode/voice/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_phone forName:@"phone"];
    [params addParam:self.req_token forName:@"token"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

@end
