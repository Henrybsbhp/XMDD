//
//  NSString+CKExpansion.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-18.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

@implementation NSString (CKExpansion)
- (NSString *)append:(NSString *)string2
{
    if (string2 == nil) {
        return self;
    }
    return [self stringByAppendingString:string2];
}

@end
