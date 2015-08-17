//
//  NSString+PhoneNumber.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NSString+PhoneNumber.h"

@implementation NSString (PhoneNumber)

- (BOOL)isPhoneNumber
{
    NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{10}$" options:0 error:nil];
    if ([regexp numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0) {
        return YES;
    }
    return NO;
}


@end
