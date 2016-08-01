//
//  RACSignal+Extension.h
//  ROKI
//
//  Created by jiangjunchen on 15/1/8.
//  Copyright (c) 2015年 legent. All rights reserved.
//

#import "RACSignal.h"

@interface RACSignal (Extension)

- (RACSignal *)takeUntilForCell:(id)cell;
- (RACSignal *)ignoreError;
- (RACSignal *)doEmpty:(void(^)(void))emptyBlock;

- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
                           error:(void (^)(NSError *error))errorBlock
                          others:(void (^)(void))otherBlock;

- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
                           error:(void (^)(NSError *error))errorBlock
                         success:(void (^)(BOOL isEmpty))successBlock;


@end
