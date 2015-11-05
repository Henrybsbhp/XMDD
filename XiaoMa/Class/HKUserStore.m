//
//  HKUserStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKUserStore.h"

@implementation HKUserStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self observeCurrentUser];
    }
    return self;
}

- (void)observeCurrentUser
{
    @weakify(self);
    RACDisposable *dsp = [[[RACObserve(gAppMgr, myUser) distinctUntilChanged] skip:1] subscribeNext:^(id x) {
        @strongify(self);
        [self.cache removeAllObjects];
        [self resetAllTimetags];
        if (!x) {
            [self sendEvent:[CKStoreEvent eventWithSignal:[RACSignal return:nil] code:kCKStoreEventReload object:nil]];
        }
        else {
            [self reloadDataWithCode:kCKStoreEventReload];
        }
    }];
    [[self rac_deallocDisposable] addDisposable:dsp];
}

- (void)reloadDataWithCode:(NSInteger)code
{
}

@end
