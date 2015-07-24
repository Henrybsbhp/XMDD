//
//  PushManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol PushManagerDelegate <NSObject>
@optional
- (void)registerDeviceToken:(NSData *)deviceToken;
- (void)handleNofitication:(NSDictionary *)info forApplication:(UIApplication *)application;
@end

@interface PushManager : NSObject<PushManagerDelegate>

- (void)setupWithOptions:(NSDictionary *)launchOptions;

@end


