//
//  CKMutableEvent.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKEventPromise.h"
#import "CKEvent.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation CKEventPromise

#pragma mark - CKEventPromiseDelegate
- (CKEventPromise *)delay:(NSTimeInterval)interval
{
    self.delayInterval = interval;
    return self;
}

- (CKEventPromise *)ignoreError
{
    self.shouldIgnoreError = YES;
    return self;
}

- (CKEventPromise *)mapSignal:(RACSignal *(^)(RACSignal *signal))block
{
    self.eventObject = block(self.eventObject);
    return self;
}


- (CKEventPromise *)setObject:(id)object
{
    self.eventObject = object;
    return self;
}

- (CKEventPromise *)setUserInfo:(NSDictionary *)userInfo
{
    self.eventUserInfo = userInfo;
    return self;
}

- (RACSignal *)send
{
    CKEvent *event = [CKEvent eventWithName:self.eventName object:self.eventObject signal:self.eventSignal];
    return [event send];
}


@end
