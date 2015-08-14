//
//  AppDelegate.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKPushManager.h"
#import "VcodeLoginVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) HKPushManager *pushMgr;
@property (nonatomic, weak) VcodeLoginVC *loginVC;

- (void)resetRootViewController:(UIViewController *)vc;
@end

