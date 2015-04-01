//
//  NSString+Compare.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-10.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

@implementation NSString (Compare)

- (BOOL)equalByCaseInsensitive:(NSString *)string
{
    return [self compare:string options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

@end
