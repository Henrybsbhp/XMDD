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
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.simulateResponse = YES;
    }
    return self;
}
- (RACSignal *)rac_postRequest
{
    self.req_method = @"/pwd/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:[self encryptPassword:self.req_newPwd] forName:@"newpwd"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (NSString *)encryptPassword:(NSString *)pwd
{
    NSString *key = self.skey;
    return [DesUtil encryptUseDES:[pwd md5] key:key];
}

- (id)returnSimulateResponse
{
    return @{@"rc":@0};
}

@end
