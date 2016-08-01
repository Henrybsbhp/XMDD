//
//  RACSignal+Extension.m
//  ROKI
//
//  Created by jiangjunchen on 15/1/8.
//  Copyright (c) 2015年 legent. All rights reserved.
//

#import "RACSignal+Extension.h"
#import <ReactiveCocoa.h>

@implementation RACSignal (Extension)

- (RACSignal *)takeUntilForCell:(id)cell
{
    return [[[self distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]]
            deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)ignoreError
{
    return [self catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }];
}

- (RACSignal *)doEmpty:(void(^)(void))empty
{
    __block BOOL isNexted = NO;
    return [[self doNext:^(id x) {
        
        isNexted = YES;
    }] doCompleted:^{
        
        if (!isNexted) {
            empty();
        }
    }];
}

- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
                           error:(void (^)(NSError *error))errorBlock
                          others:(void (^)(void))otherBlock
{
    __block BOOL isTouched = NO;
    return [self subscribeNext:^(id x) {
        
        isTouched = YES;
        nextBlock(x);
    } error:^(NSError *error) {
        
        isTouched = YES;
        errorBlock(error);
    } completed:^{
        
        if (!isTouched) {
            otherBlock();
        }
    }];
}

- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
                           error:(void (^)(NSError *error))errorBlock
                         success:(void (^)(BOOL isEmpty))successBlock
{
    __block BOOL isTouched = NO;
    return [self subscribeNext:^(id x) {
        
        isTouched = YES;
        nextBlock(x);
    } error:^(NSError *error) {
        
        isTouched = YES;
        errorBlock(error);
    } completed:^{
        
        successBlock(!isTouched);
    }];
}

@end
