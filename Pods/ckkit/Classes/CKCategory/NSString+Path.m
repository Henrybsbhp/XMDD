//
//  NSString+Path.m
//  JTReader
//
//  Created by jiangjunchen on 13-9-26.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

@implementation NSString (Path)
- (BOOL)makeSurePathExists
{
    if (![self pathExists])
    {
        BOOL isSuccessCreateDir = [[NSFileManager defaultManager] createDirectoryAtPath:self
                                                            withIntermediateDirectories:YES
                                                                             attributes:nil
                                                                                  error:nil];
        if (!isSuccessCreateDir)
        {
            NSLog(@"Fatal error: unable to create directory %@", self);
            return NO;
        }
    }

    return YES;
}

- (BOOL)pathExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self];
}

@end
