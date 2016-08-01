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
#import "HKCatchErrorModel.h"
#import "PasteboardModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) HKPushManager *pushMgr;
@property (nonatomic, weak) VcodeLoginVC *loginVC;
@property (nonatomic, strong) HKCatchErrorModel *errorModel;
@property (nonatomic, strong) PasteboardModel *pasteboardoModel;
///handleOpenUrl的队列
@property (nonatomic, strong) JTQueue *openUrlQueue;

- (void)resetRootViewController:(UIViewController *)vc;
@end

