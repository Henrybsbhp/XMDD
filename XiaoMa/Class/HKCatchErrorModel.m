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
@property (nonatomic, weak) CXAlertView *alertView;
@end
@implementation HKCatchErrorModel

- (void)catchNetworkingError
{
    [gNetworkMgr setCatchErrorHandler:^RACSignal *(BaseOp *op, NSError *error) {
        
        NSInteger code = error.code;
        //token失效
        if (code == -2001) {
            return [self retryWithOp:op withError:error];
        }
        //token非法
        else if (code == -2002) {
            [HKLoginModel logout];
            [self gotoRootViewWithAlertTitle:@"登出通知" msg:@"您的本次登录已经失效了,请重新登录。"];
        }
        //被抢登
        else if (code == -2003 && !self.alertView) {
            [HKLoginModel logout];
            [self gotoRootViewWithAlertTitle:@"登出通知" msg:@"您的账号已经在其他设备登录,请重新登录后修改密码,确保帐号安全。"];
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
    [gNetworkMgr.apiManager.operationQueue cancelAllOperations];
    [gNetworkMgr.mediaClient.operationQueue cancelAllOperations];
    [gAppMgr resetWithAccount:nil];
    [SVProgressHUD dismiss];
}

- (void)gotoRootViewWithAlertTitle:(NSString *)title msg:(NSString *)msg
{
    [self clearAllOperations];
    if (self.alertView) {
        return;
    }
    CXAlertView *alert = [[CXAlertView alloc] initWithTitle:title message:msg cancelButtonTitle:nil];
    [alert addButtonWithTitle:@"确定" type:0 handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        [alertView dismiss];
        [gAppMgr.navModel.curNavCtrl popToRootViewControllerAnimated:YES];
    }];
    self.alertView = alert;
    [alert show];
}

@end
