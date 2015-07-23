//
//  LoginViewModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKLoginModel.h"
#import "XiaoMa.h"
#import "VCodeInputField.h"

@interface LoginViewModel : NSObject
@property (nonatomic, strong) HKLoginModel *loginModel;
@property (nonatomic, strong, readonly) RACSubject *rac_loginSuccess;
@property (nonatomic, weak) UIViewController *originVC;

- (void)dismissForTargetVC:(UIViewController *)targetVC forSucces:(BOOL)success;
///判断是否登录，如果未登录直接进入登录流程
+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC;
+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC originVC:(UIViewController *)originVC;

@end
