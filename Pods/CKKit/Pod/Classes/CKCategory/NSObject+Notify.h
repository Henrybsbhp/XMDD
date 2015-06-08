//
//  NSObject+Notify.h
//  JTReader
//
//  Created by jiangjunchen on 13-10-24.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CKNotifyBlock)(NSNotification *note, id weakSelf);

@interface NSObject (Notify)

///监听通知（如果self被释放，将会自动清除通知，不需要手动停止监听）
- (void)listenNotificationByName:(NSString *)name withNotifyBlock:(CKNotifyBlock)block;
- (BOOL)isListenedNotificationByName:(NSString *)name;

- (void)postCustomNotification:(NSNotification *)ntf;
- (void)postCustomNotificationName:(NSString *)aName object:(id)anObject;
- (void)postCustomNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

///主动停止通知监听
- (void)cancelAllListenedNotifications;
- (void)cancelListenNotificationByName:(NSString *)name;
@end

