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
    if (step > 0) {
        NSMutableArray *subStrs = [NSMutableArray array];
        NSInteger length = step;
        for (NSUInteger i = 0; i < self.length; i += step) {
            if (i + step > self.length) {
                length = self.length - i;
            }
            [subStrs addObject:[self substringFromIndex:i length:length]];
        }
        return [subStrs componentsJoinedByString:replacement];
    }
    return self;
}

@end
