//
//  LoginViewModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKLoginModel.h"
#import "Xmdd.h"
#import "VCodeInputField.h"

@interface LoginViewModel : NSObject
@property (nonatomic, strong) HKLoginModel *loginModel;
@property (nonatomic, weak) UIViewController *originVC;

- (void)dismissForTargetVC:(UIViewController *)targetVC forSucces:(BOOL)success;
///判断是否登录，如果未登录直接进入登录流程
+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC;
///判断是否登录，如果未登录直接进入登录流程,登录成功后的操作
+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC withLoginSuccessAction:(void (^)(void))successBlock;

+ (BOOL)loginIfNeededForTargetViewController:(UIViewController *)targetVC originVC:(UIViewController *)originVC withLoginSuccessAction:(void (^)(void))successBlock;

@end
