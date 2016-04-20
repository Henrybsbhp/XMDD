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
#import "CXAlertView.h"

@interface HKCatchErrorModel ()

@end
@implementation HKCatchErrorModel

- (void)catchNetworkingError
{
    [gNetworkMgr setCatchErrorHandler:^RACSignal *(BaseOp *op, NSError *error) {
        
        NSInteger code = error.code;
        //token失效
//        if (code == -2001) {
//            return [self retryWithOp:op withError:error];
//        }
        //token非法或失效
        if (code == -2002 || code == -2001) {
            [HKLoginModel logout];
            [self gotoRootViewWithAlertTitle:@"登出通知" msg:@"您的本次登录已经失效了,请重新登录。"];
            error = [NSError errorWithDomain:@"" code:error.code userInfo:nil];
        }
        //被抢登
        else if (code == -2003 && !self.alertView) {
            [HKLoginModel logout];
            [self gotoRootViewWithAlertTitle:@"登出通知" msg:@"您的账号已经在其他设备登录,请重新登录,确保账号安全。"];
            error = [NSError errorWithDomain:@"" code:error.code userInfo:nil];
        }
        return [RACSignal error:error];
    }];
}

#pragma mark - Private
- (RACSignal *)retryWithOp:(BaseOp *)op withError:(NSError *)error
{
    NSInteger count = [[op associatedObjectForKey:@"hk_retryCount"] integerValue];
    if (count < 2) {
        [op setAssociatedObject:@(++count) forKey:@"hk_retryCount"];
    }
    else {
        [self gotoRootViewWithAlertTitle:@"登出通知" msg:@"您的本次登录已经失效了,请重新登录。"];
        return [RACSignal error:error];
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

#pragma mark - Utilities
- (void)clearAllOperations
{
    for (AFHTTPRequestOperation *afop in [gNetworkMgr.apiManager.operationQueue operations]) {
        BaseOp *op = afop.customObject;
        if (op.security) {
            [op cancel];
        }
    }
    [gNetworkMgr.mediaClient.operationQueue cancelAllOperations];
    [gAppMgr resetWithAccount:nil];
    [gToast dismiss];
}

- (void)gotoRootViewWithAlertTitle:(NSString *)title msg:(NSString *)msg
{
    [self clearAllOperations];
    //已经有个对话框在显示，或者用户已经退出登录，则直接返回
    if (self.alertView) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
        if (index.integerValue == 0) {
            //已经在登录页面了，则忽略
            if (gAppDelegate.loginVC) {
                return ;
            }
            CKAfter(0.1, ^{
                UIViewController *orginVC = [gAppMgr.navModel.curNavCtrl.viewControllers safetyObjectAtIndex:0];
                [LoginViewModel loginIfNeededForTargetViewController:gAppMgr.navModel.curNavCtrl originVC:orginVC];
            });
            self.alertView = nil;
        }
    }];
    self.alertView = alert;
    [alert show];
}

@end
