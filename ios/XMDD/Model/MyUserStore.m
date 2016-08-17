//
//  MyUserStore.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyUserStore.h"

@implementation MyUserStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self observeMyUser];
    }
    return self;
}

- (void)observeMyUser
{
    @weakify(self);
    RACDisposable *dsp = [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self resetForMyUser:x];
    }];
    [[self rac_deallocDisposable] addDisposable:dsp];
}


- (void)resetForMyUser:(JTUser *)user {
    
}

@end
