//
//  CKEvent.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CKEvent.h"

#define kEventNamePrefix    @"CKKit.CKEvent."

@implementation CKEvent

+ (NSString *)wholeEventName:(NSString *)name
{
    return [kEventNamePrefix stringByAppendingString:name];
}

+ (CKEvent *)eventWithName:(NSString *)aName signal:(RACSignal *)signal
{
    return [self eventWithName:aName object:nil userInfo:nil signal:signal];
}

+ (CKEvent *)eventWithName:(NSString *)aName object:(id)object signal:(RACSignal *)signal
{
    return [self eventWithName:aName object:object signal:signal];
}

+ (CKEvent *)eventWithName:(NSString *)aName object:(id)object userInfo:(NSDictionary *)userInfo signal:(RACSignal *)signal
{
    CKEvent *event = [self notificationWithName:[self wholeEventName:aName] object:object userInfo:userInfo];
    event->_signal = signal;
    return event;
}

- (CKEvent *)mapSignal:(RACSignal *(^)(RACSignal *signal))block
{
    RACSignal *signal = block(self.signal);
    return [CKEvent eventWithName:self.name object:self.object userInfo:self.userInfo signal:signal];
}

- (RACSignal *)send
{
    [[NSNotificationCenter defaultCenter] postNotification:self];
    return self.signal;
}

@end

@implementation RACSignal (CKEvent)

- (CKEvent *)eventWithName:(NSString *)aName
{
    return [self eventWithName:aName object:nil userInfo:nil];
}

- (CKEvent *)eventWithName:(NSString *)aName object:(id)object
{
    return [self eventWithName:aName object:object userInfo:nil];
}

- (CKEvent *)eventWithName:(NSString *)aName object:(id)object userInfo:(NSDictionary *)userInfo
{
    return [CKEvent eventWithName:aName object:object userInfo:userInfo signal:self];
}


@end