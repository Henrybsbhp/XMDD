//
//  UpdateUserInfoOp.m
//  XiaoMa
//
//  Created by jt on 15-5-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UpdateUserInfoOp.h"
#import "NSDate+DateForText.h"

@implementation UpdateUserInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/basicinfo/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.nickname)
    {
        [params addParam:self.nickname forName:@"nickname"];
    }
    if (self.avatarUrl)
    {
        [params addParam:self.avatarUrl forName:@"avatar"];
    }
    if (self.sex)
    {
        [params addParam:@(self.sex) forName:@"sex"];
    }
    if (self.birthday)
    {
        [params addParam:[self.birthday dateFormatForDT8] forName:@"birthday"];
    }
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
