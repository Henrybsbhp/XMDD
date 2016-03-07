//
//  CKEvent.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CKEvent.h"
#import "CKDispatcher.h"

@implementation CKEvent

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
    return [[self alloc] initWithName:aName object:object userInfo:userInfo signal:signal];
}

- (instancetype)initWithName:(NSString *)aName object:(id)object userInfo:(NSDictionary *)userInfo signal:(RACSignal *)signal
{
    self = [self init];
    if (self) {
        _name = aName;
        _object = object;
        _userInfo = userInfo;
        _signal = signal;
    }
    return self;
}

- (CKEvent *)mapSignal:(RACSignal *(^)(RACSignal *signal))block
{
    RACSignal *signal = block(self.signal);
    return [CKEvent eventWithName:self.name object:self.object userInfo:self.userInfo signal:signal];
}

- (RACSignal *)send
{
    [[CKDispatcher sharedDispatcher] sendEvent:self];
    return self.signal;
}

- (RACSignal *)sendAndIgnoreError
{
    RACSignal *signal = self.signal;
    [[CKDispatcher sharedDispatcher] sendEvent:[self mapSignal:^RACSignal *(RACSignal *signal) {
        return [signal catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }]];
    return signal;
}

- (CKEvent *)setObject:(id)object
{
    return [CKEvent eventWithName:self.name object:object userInfo:self.userInfo signal:self.signal];
}

- (CKEvent *)setUserInfo:(NSDictionary *)userInfo
{
    return [CKEvent eventWithName:self.name object:self.object userInfo:userInfo signal:self.signal];
}

- (BOOL)isEqualForAnyoneOfNames:(NSArray *)names
{
    return [names firstObjectByFilteringOperator:^BOOL(NSString *name) {
        return [self.name isEqualToString:name];
    }];
}

- (BOOL)isEqualForName:(NSString *)name
{
    if ([self.name isEqualToString:name]) {
        return YES;
    }
    return NO;
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