//
//  NSObject+Notify.m
//  JTReader
//
//  Created by jiangjunchen on 13-10-24.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "NSObject+Notify.h"
#import <objc/runtime.h>

@interface CustomDictionary : NSObject
@property (nonatomic, strong) NSMutableDictionary *mMutableDictionary;

- (void)removeObserverForKey:(NSString *)key;
@end

@implementation CustomDictionary
- (id)init
{
    self = [super init];
    if (self)
    {
        self.mMutableDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [self removeAllObservers];
}

- (void)setObserver:(id)observer forKey:(NSString *)key
{
    if (!self.mMutableDictionary)
    {
        self.mMutableDictionary = [NSMutableDictionary dictionary];
    }
    [self.mMutableDictionary setObject:observer forKey:key];
}

- (id)observerForKey:(NSString *)key
{
    return self.mMutableDictionary[key];
}

- (void)removeAllObservers
{
    NSArray *allValues = self.mMutableDictionary.allValues;
    for (id observer in allValues)
    {
        [self removeObserver:observer];
    }
}

- (void)removeObserverForKey:(NSString *)key
{
    id observer = [self.mMutableDictionary objectForKey:key];
    if (observer)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:key object:nil];
        [self.mMutableDictionary removeObjectForKey:observer];
        if (self.mMutableDictionary.count == 0)
        {
            self.mMutableDictionary = nil;
        }
    }
}

- (void)removeObserver:(id)observer
{
    if (observer)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}
@end

@implementation NSObject (Notify)
static char customDictionaryKey;

#pragma mark - Listen notifaction
- (void)listenNotificationByName:(NSString *)name withNotifyBlock:(CKNotifyBlock)block
{
    __weak id blockSelf = self;
    void (^tempBlock)(NSNotification *) = ^(NSNotification *note) {
        if (block)
        {
            block(note, blockSelf);
        }
    };
    NSOperationQueue *op = [NSOperationQueue mainQueue];
    id observer = [[NSNotificationCenter defaultCenter]
                            addObserverForName:name object:nil queue:op usingBlock:tempBlock];
    CustomDictionary *dic = objc_getAssociatedObject(self, &customDictionaryKey);
    if (!dic)
    {
        dic = [[CustomDictionary alloc] init];
        objc_setAssociatedObject(self, &customDictionaryKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [dic setObserver:observer forKey:name];
}

- (BOOL)isListenedNotificationByName:(NSString *)name
{
    CustomDictionary *dic = objc_getAssociatedObject(self, &customDictionaryKey);
    if (dic)
    {
        if ([dic observerForKey:name])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Post notifaction
- (void)postCustomNotification:(NSNotification *)ntf
{
    [[NSNotificationCenter defaultCenter] postNotification:ntf];
}

- (void)postCustomNotificationName:(NSString *)aName object:(id)anObject
{
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject];
}

- (void)postCustomNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

#pragma mark - Remove notifaction observer
- (void)cancelAllListenedNotifications
{
    // REV @jiangjunchen wtf?
    CustomDictionary *dic = objc_getAssociatedObject(self, &customDictionaryKey);
    if (dic)
    {
        objc_setAssociatedObject(self, &customDictionaryKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        dic = nil;
    }
}

- (void)cancelListenNotificationByName:(NSString *)name
{
    // REV @jiangjunchen wtf?
    CustomDictionary *dic = objc_getAssociatedObject(self, &customDictionaryKey);
    if (dic)
    {
        [dic removeObserverForKey:name];
    }
}


@end
