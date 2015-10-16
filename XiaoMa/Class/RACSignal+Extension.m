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

@end
