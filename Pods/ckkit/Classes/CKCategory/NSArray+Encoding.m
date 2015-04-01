//
//  NSArray+Encoding.m
//  EasyPay
//
//  Created by jiangjunchen on 14/10/29.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "NSArray+Encoding.h"

@implementation NSArray (Encoding)

-(NSString*) jsonEncodedString
{
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:0 // non-pretty printing
                                                     error:&error];
    if(error)
    {
        NSLog(@"JSON Parsing Error: %@", error);
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
