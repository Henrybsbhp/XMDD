//
//  UpdatePwdOp.m
//  XiaoMa
//
//  Created by jt on 15-4-13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UpdatePwdOp.h"
#import "DesUtil.h"
#import "NSString+MD5.h"

@implementation UpdatePwdOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/pwd/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:[self encryptPassword:self.theNewPwd] forName:@"newpwd"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (NSString *)encryptPassword:(NSString *)pwd
{
    NSString *key = self.skey;
    return [DesUtil encryptUseDES:[pwd md5] key:key];
}

@end
