//
//  MyCarStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyCarStore.h"

@interface MyCarStore ()
@property (nonatomic, strong) RACDisposable *reqDisposable;
@end
@implementation MyCarStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.carModel = [[MyCarsModel alloc] init];
    }
    return self;
}

- (void)reloadDataWithCode:(NSInteger)code
{
    self.carModel = [[MyCarsModel alloc] init];
    [self observeCarModelDoRequest];
    RACSignal *evt = [[[self.carModel rac_fetchData] map:^id(JTQueue *queue) {
        return [queue allObjects];
    }] skip:1];
    [self sendEvent:evt withCode:kCKStoreEventReload];
}

- (void)observeCarModelDoRequest
{
    [self.reqDisposable dispose];
    @weakify(self);
    self.reqDisposable = [[self.carModel rac_observeDataWithDoRequest:nil] subscribeNext:^(JTQueue *queue) {
        @strongify(self);
        [self sendEvent:[RACSignal return:[queue allObjects]] withCode:kCKStoreEventReload];
    }];
}
@end
