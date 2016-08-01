//
//  NSString+UUID.m
//  ZJUMobile
//
//  Created by jiangjunchen on 13-7-22.
//  Copyright (c) 2013年 jtang. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)uuidString
{
    CFUUIDRef UUID_obj = CFUUIDCreate(kCFAllocatorDefault);
    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(UUID_obj);
    NSString *result = [NSString stringWithFormat:
                        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        bytes.byte0, bytes.byte1, bytes.byte2, bytes.byte3, bytes.byte4, bytes.byte5,
                        bytes.byte6, bytes.byte7, bytes.byte8, bytes.byte9, bytes.byte10, bytes.byte11,
                        bytes.byte12, bytes.byte13, bytes.byte14, bytes.byte15];
    CFRelease(UUID_obj);
    return result;
}
@end
