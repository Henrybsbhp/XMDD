//
//  PushManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTQueue.h"
@protocol PushManagerDelegate <NSObject>
@optional
- (void)registerDeviceToken:(NSData *)deviceToken;
- (void)handleNofitication:(NSDictionary *)info forApplication:(UIApplication *)application;
@end

@interface PushManager : NSObject<PushManagerDelegate>
/// 后台推送队列
@property (nonatomic, strong) JTQueue *notifyQueue;
- (void)setupWithOptions:(NSDictionary *)launchOptions;

@end


