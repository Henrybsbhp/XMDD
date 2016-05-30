//
//  LoginViewModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "LoginViewModel.h"
#import "VcodeLoginVC.h"
#import "XiaoMa.h"

@implementation LoginViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loginModel = [HKLoginModel new];
    }
    return self;
}

- (void)dismissForTargetVC:(UIViewController *)targetVC forSucces:(BOOL)success
{
    if (self.originVC) {
        [targetVC.navigationController popToViewController:self.originVC animated:YES];
        gAppDelegate.loginVC = nil;
        return;
    }
    [targetVC dismissViewControllerAnimated:YES completion:^{
        gAppDelegate.loginVC = nil;
    }];
}

///判断是否登录，如果未登录直接进入登录流程
+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC
{
    return [LoginViewModel loginIfNeededForTargetViewController:targetVC originVC:nil withLoginSuccessAction:nil];
}

///判断是否登录，如果未登录直接进入登录流程,登录成功后的操作
+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC withLoginSuccessAction:(void (^)(void))successBlock
{
    return [LoginViewModel loginIfNeededForTargetViewController:targetVC originVC:nil withLoginSuccessAction:successBlock];
}

+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC originVC:(UIViewController *)originVC withLoginSuccessAction:(void (^)(void))successBlock
{
    if (gAppMgr.myUser) {
        return YES;
    }
    VcodeLoginVC *vc = [UIStoryboard vcWithId:@"VcodeLoginVC" inStoryboard:@"Login"];
    if (successBlock)
    {
        vc.loginSuccessAction = successBlock;
    }
    if ([targetVC isKindOfClass:[HKNavigationController class]]) {
        vc.model.originVC = originVC;
        [(HKNavigationController *)targetVC pushViewController:vc animated:YES];
    }
    else {
        [targetVC presentViewController:vc animated:YES completion:nil];
    }
    gAppDelegate.loginVC = vc;
    return NO;
}
@end
