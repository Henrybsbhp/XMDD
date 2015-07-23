//
//  AppDelegate.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKPushManager.h"
#import "LoginVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) HKPushManager *pushMgr;
@property (nonatomic, weak) LoginVC *loginVC;

- (void)resetRootViewController:(UIViewController *)vc;
@end

