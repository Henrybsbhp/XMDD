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
    if (gAppMgr.myUser) {
        return YES;
    }
    LoginVC *vc = [UIStoryboard vcWithId:@"LoginVC" inStoryboard:@"Login"];
    JTNavigationController *nav = [[JTNavigationController alloc] initWithRootViewController:vc];
    [targetVC presentViewController:nav animated:YES completion:nil];
    return NO;
}
@end
