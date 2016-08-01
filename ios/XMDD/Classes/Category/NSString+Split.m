//
//  NSString+Split.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NSString+Split.h"

@implementation NSString (Split)

- (NSString *)splitByStep:(NSUInteger)step replacement:(NSString *)replacement
{
    return [self splitByStep:step replacement:replacement count:NSUIntegerMax];
}

- (NSString *)splitByStep:(NSUInteger)step replacement:(NSString *)replacement count:(NSUInteger)count
{
    if (step > 0) {
        NSMutableArray *subStrs = [NSMutableArray array];
        NSInteger length = step;
        NSUInteger i;
        for (i = 0; i < MIN(self.length, step*count); i += step) {
            if (i + step > self.length) {
                length = self.length - i;
            }
            [subStrs addObject:[self substringFromIndex:i length:length]];
        }
        if (i < MAX(0, self.length - 1)) {
            [subStrs addObject:[self substringFromIndex:i]];
        }
        return [subStrs componentsJoinedByString:replacement];
    }
    return self;
}

@end
