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

@end
