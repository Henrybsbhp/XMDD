//
//  HKCatchErrorModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKCatchErrorModel.h"
#import "XiaoMa.h"
#import "HKLoginModel.h"

@implementation HKCatchErrorModel

+ (void)catchNetworkingError
{
    [gNetworkMgr setCatchErrorHandler:^RACSignal *(BaseOp *op, NSError *error) {
        
        NSInteger code = error.code;
        //token失效或非法
        if (code == -2001 || code == -2002) {
            return [self retryWithOp:op withError:error];
        }
        return [RACSignal error:error];
    }];
}

#pragma mark - Private
+ (RACSignal *)retryWithOp:(BaseOp *)op withError:(NSError *)error
{
    NSInteger count = [[op associatedObjectForKey:@"hk_retryCount"] integerValue];
    if (count < 2)
    {
        [op setAssociatedObject:@(++count) forKey:@"hk_retryCount"];
    }
    else
    {
//        [SVProgressHUD showErrorWithStatus:@"账号验证失败了，请重新登录"];
        return [RACSignal error:[NSError errorWithDomain:@"账号验证失败了，请重新登录" code:error.code userInfo:nil]];
    }
    HKLoginModel *loginModel = [[HKLoginModel alloc] init];
    DebugLog(@"Retry Operation: %@ with id %@", op, @(op.req_id));
    return [[[loginModel rac_retryLoginFastWithOldToken:op.token] flattenMap:^RACStream *(BaseOp *validateOp) {
        DebugLog(@"Old token: %@\n"
                 "New token: %@", op.token, validateOp.token);
        op.skey = validateOp.skey;
        op.token = validateOp.token;
        return [op rac_postRequest];
    }] doError:^(NSError *error) {
        
        [gNetworkMgr handleError:error forOp:op];
    }];
}

@end
