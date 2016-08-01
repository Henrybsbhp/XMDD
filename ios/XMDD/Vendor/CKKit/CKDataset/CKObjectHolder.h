//
//  CKObjectHolder.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKObjectHolder : NSObject
@property (nonatomic, strong, readonly) id object;
@property (nonatomic, assign, readonly) NSInteger count;

+ (instancetype)holderWithObject:(id)object;
- (void)increaseCount;
- (BOOL)decreaseCount;

@end
