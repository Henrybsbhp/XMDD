//
//  LoginViewModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "LoginViewModel.h"
#import "LoginVC.h"
#import "XiaoMa.h"

@implementation LoginViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loginModel = [HKLoginModel new];
        _rac_loginSuccess = [RACSubject subject];
    }
    return self;
}

- (void)dismissForTargetVC:(UIViewController *)targetVC forSucces:(BOOL)success
{
    if (self.originVC) {
        [targetVC.navigationController popToViewController:self.originVC animated:YES];
        if (success) {
            [self.rac_loginSuccess sendNext:@YES];
            [self.rac_loginSuccess sendCompleted];
        }
        return;
    }
    [targetVC dismissViewControllerAnimated:YES completion:^{
        if (success) {
            [self.rac_loginSuccess sendNext:@YES];
            [self.rac_loginSuccess sendCompleted];
        }
    }];
}

///判断是否登录，如果未登录直接进入登录流程
+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC
{
    return [LoginViewModel loginIfNeededForTargetViewController:targetVC originVC:nil];
}

+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC originVC:(UIViewController *)originVC
{
    if (gAppMgr.myUser) {
        return YES;
    }
    LoginVC *vc = [UIStoryboard vcWithId:@"LoginVC" inStoryboard:@"Login"];
    if ([targetVC isKindOfClass:[UINavigationController class]]) {
        vc.model.originVC = originVC;
        [(UINavigationController *)targetVC pushViewController:vc animated:YES];
    }
    else {
        JTNavigationController *nav = [[JTNavigationController alloc] initWithRootViewController:vc];
        [targetVC presentViewController:nav animated:YES completion:nil];
    }
    gAppDelegate.loginVC = vc;
    return NO;

}
@end
