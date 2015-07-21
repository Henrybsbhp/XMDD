//
//  PushManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PushManager.h"

@implementation PushManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _notifyQueue = [[JTQueue alloc] init];
    }
    return self;
}

- (void)registerDeviceToken:(NSData *)deviceToken
{
    
}

- (void)setupWithOptions:(NSDictionary *)launchOptions
{
    //如果需要支持 iOS8,请加上这些代码并在 iOS6 中编译
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
    {
        UIRemoteNotificationType myTypes =  UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert|
        UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    };
    
    NSDictionary *info = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (info) {
        [self handleNofitication:info forApplication:[UIApplication sharedApplication]];
    }
}

- (void)handleNofitication:(NSDictionary *)info forApplication:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    DebugLog(@"%@ Received push info:\n%@", @"•••••••••••", info);
}
@end
