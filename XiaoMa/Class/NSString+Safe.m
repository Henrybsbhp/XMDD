//
//  NSString+Safe.m
//  XiaoMa
//
//  Created by jt on 15/9/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NSString+Safe.h"

@implementation NSString (Safe)

- (NSString *)safteySubstringFromIndex:(NSInteger)i
{
    if (i > self.length)
        return nil;
    return [self substringFromIndex:i];
}

- (NSString *)safteySubstringToIndexIndex:(NSInteger)i
{
    if (i > self.length)
        return nil;
    return [self substringToIndex:i];
}
@end
