//
//  MyUserStore.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyUserStore.h"
#define kDefTimetagKey @"$DefTimetag"

@interface MyUserStore ()
@property (nonatomic, strong) NSMutableDictionary *timetagDict;
@end

@implementation MyUserStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.updateDuration = 6 * 60 * 60;
        self.timetagDict = [NSMutableDictionary dictionary];
        [self observeMyUser];
    }
    return self;
}

- (void)observeMyUser
{
    @weakify(self);
    RACDisposable *dsp = [[[RACObserve(gAppMgr, myUser) distinctUntilChanged] skip:1] subscribeNext:^(id x) {
        @strongify(self);
        [self resetForMyUser:x];
    }];
    [[self rac_deallocDisposable] addDisposable:dsp];
}


- (void)resetForMyUser:(JTUser *)user {
}

#pragma mark - Timetag
- (BOOL)needUpdateTimetagForKey:(NSString *)key
{
    if (!key) {
        key = kDefTimetagKey;
    }
    NSTimeInterval timetag = [[self.timetagDict objectForKey:key] doubleValue];
    return [[NSDate date] timeIntervalSince1970] - timetag > self.updateDuration;
}

- (void)updateTimetagForKey:(NSString *)key
{
    if (!key) {
        key = kDefTimetagKey;
    }
    [self.timetagDict setObject:@([[NSDate date] timeIntervalSince1970]) forKey:key];
}

- (void)resetTimetagForKey:(NSString *)key {
    if (!key) {
        key = kDefTimetagKey;
    }
    [self.timetagDict removeObjectForKey:key];
}


- (void)resetAllTimetags
{
    [self.timetagDict removeAllObjects];
}



@end
