//
//  UserStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "UserStore.h"

#define kDefTimetagKey @"$DefTimetag"

@interface UserStore ()
@property (nonatomic, strong) NSMutableDictionary *timetagDict;
@end

@implementation UserStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.updateDuration = 12 * 60 * 60;
        self.timetagDict = [NSMutableDictionary dictionary];
        [self observeCurrentUser];
    }
    return self;
}

- (void)observeCurrentUser
{
    @weakify(self);
    RACDisposable *dsp = [[[RACObserve(gAppMgr, myUser) distinctUntilChanged] skip:1] subscribeNext:^(id x) {
        @strongify(self);
        [self reloadForUserChanged];
    }];
    [[self rac_deallocDisposable] addDisposable:dsp];
}

- (void)reloadForUserChanged
{
    
}

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

- (void)resetAllTimetags
{
    [self.timetagDict removeAllObjects];
}

@end
