//
//  NSNumber+Safety.m
//  XiaoMa
//
//  Created by fuqi on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "NSNumber+Safety.h"

@implementation NSNumber (Safety)

- (BOOL)safetyEqualToNumber:(NSNumber *)number
{
    if (!number)
        return NO;
    return [self isEqualToNumber:number];
}

@end
