//
//  CKDispatcher.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "CKDispatcher.h"
#import "CKEvent.h"

@implementation CKDispatcher

+ (instancetype)sharedDispatcher
{
    static dispatch_once_t onceToken;
    static CKDispatcher *g_dispatcher;
    dispatch_once(&onceToken, ^{
        g_dispatcher = [[CKDispatcher alloc] init];
    });
    return g_dispatcher;
}

- (void)sendEvent:(CKEvent *)event
{
    [self postNotificationName:event.name object:nil userInfo:@{@"event":event}];
}

- (RACSignal *)rac_addObserverForEventName:(NSString *)evtName
{
    return [[self rac_addObserverForName:evtName object:nil] map:^id(NSNotification *notify) {
        return notify.userInfo[@"event"];
    }];
}

@end
