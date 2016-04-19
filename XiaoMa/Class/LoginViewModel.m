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
        _rac_loginSuccess = [RACSubject subject];
    }
    return self;
}

- (void)dismissForTargetVC:(UIViewController *)targetVC forSucces:(BOOL)success
{
    if (self.originVC) {
        NSLog(@"[self.navigationController %@",targetVC.navigationController);
        
        [targetVC.navigationController popToViewController:self.originVC animated:YES];
        NSLog(@"[self.navigationController %@",targetVC.navigationController);
        if (success) {
            [self.rac_loginSuccess sendNext:@YES];
            [self.rac_loginSuccess sendCompleted];
        }
        gAppDelegate.loginVC = nil;
        return;
    }
    [targetVC dismissViewControllerAnimated:YES completion:^{
        if (success) {
            [self.rac_loginSuccess sendNext:@YES];
            [self.rac_loginSuccess sendCompleted];
        }
        gAppDelegate.loginVC = nil;
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
    VcodeLoginVC *vc = [UIStoryboard vcWithId:@"VcodeLoginVC" inStoryboard:@"Login"];
    if ([targetVC isKindOfClass:[UINavigationController class]]) {
        vc.model.originVC = originVC;
        gAppMgr.isNaviBarHidden = YES;
        [(UINavigationController *)targetVC pushViewController:vc animated:YES];
    }
    else {
        [targetVC presentViewController:vc animated:YES completion:nil];
    }
    gAppDelegate.loginVC = vc;
    return NO;

}
@end
