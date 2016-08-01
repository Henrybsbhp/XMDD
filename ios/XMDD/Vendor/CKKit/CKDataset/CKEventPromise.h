//
//  CKMutableEvent.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;
@protocol CKEventPromiseDelegate;

@interface CKEventPromise : NSObject
@property (nonatomic, strong) RACSignal *eventSignal;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) id eventObject;
@property (nonatomic, strong) NSDictionary *eventUserInfo;
@property (nonatomic, assign) NSTimeInterval delayInterval;
@property (nonatomic, assign) BOOL shouldIgnoreError;

@end

@protocol CKEventPromiseDelegate <NSObject>

- (CKEventPromise *)delay:(NSTimeInterval)interval;
- (CKEventPromise *)ignoreError;
- (CKEventPromise *)mapSignal:(RACSignal *(^)(RACSignal *signal))block;
- (CKEventPromise *)setObject:(id)object;
- (CKEventPromise *)setUserInfo:(NSDictionary *)userInfo;
- (RACSignal *)send;

@end