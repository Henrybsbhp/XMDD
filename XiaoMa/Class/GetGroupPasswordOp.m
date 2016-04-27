//
//  GetGroupPasswordOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetGroupPasswordOp.h"

@implementation GetGroupPasswordOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/groupinfo/get/by-id";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_groupId forName:@"groupid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dic = rspObj;
    
    self.rsp_groupCipher = [dic stringParamForName:@"cipher"];
    self.rsp_wordForShare = [dic stringParamForName:@"word"];
    self.rsp_groupType = [dic integerParamForName:@"type"];
    
    return self;
}

@end
