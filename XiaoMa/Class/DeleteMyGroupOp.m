//
//  DeleteMyGroupOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "DeleteMyGroupOp.h"

@implementation DeleteMyGroupOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/groupinfo/delete";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.memberId forName:@"memberid"];
    [params addParam:self.groupId forName:@"groupid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    return self;
}

@end
