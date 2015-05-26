//
//  CacheModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CacheModel.h"

@interface CacheModel ()
{
    RACReplaySubject *_dataSubject;
}

@property (nonatomic, assign) NSTimeInterval currentTime;
@end

@implementation CacheModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSubject = [RACReplaySubject replaySubjectWithCapacity:1];
        _updateInterval = 60*60;
    }
    return self;
}

- (RACSignal *)rac_requestData
{
    return nil;
}

- (void)removeAllObservers
{
}

- (RACSignal *)rac_observeDataWithDoRequest:(void(^)(void))block
{
    return [[_dataSubject flattenMap:^RACStream *(id value) {
        if ([value isKindOfClass:[RACSignal class]]) {
            if (block) {
                return [(RACSignal *)value initially:block];
            }
            return value;
        }
        return [RACSignal return:value];
    }] takeUntil:[self rac_signalForSelector:@selector(removeAllObservers)]];
}

- (RACSignal *)rac_fetchData
{
    RACSignal *sig = [[self rac_requestData] doNext:^(id x) {
        self.currentTime = [[NSDate date] timeIntervalSince1970];
        _cache = x;
    }];
    [_dataSubject sendNext:sig];
    return sig;
}

- (RACSignal *)rac_fetchDataIfNeeded
{
    if (self.currentTime+self.updateInterval < [[NSDate date] timeIntervalSince1970]) {
        return [self rac_fetchData];
    }
    return [RACSignal return:self.cache];
}

- (id)updateCache:(id)newCache refreshTime:(BOOL)refresh
{
    _cache = newCache;
    if (refresh) {
        self.currentTime = [[NSDate date] timeIntervalSince1970];
    }
    [_dataSubject sendNext:newCache];
    return newCache;
}

@end
