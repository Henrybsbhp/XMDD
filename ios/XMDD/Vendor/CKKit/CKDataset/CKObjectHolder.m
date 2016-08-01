//
//  CKObjectHolder.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKObjectHolder.h"

@implementation CKObjectHolder


+ (instancetype)holderWithObject:(id)object {
    
    CKObjectHolder *holder = [[CKObjectHolder alloc] init];
    holder->_object = object;
    holder->_count = 0;
    return holder;
}

- (void)increaseCount {
    self->_count += 1;
}

- (BOOL)decreaseCount {
    if (self->_count > 0) {
        self->_count -= 1;
        return YES;
    }
    return NO;
}

@end
