//
//  DebugFormat.m
//  ZJUMobile
//
//  Created by cyclist on 13-9-8.
//  Copyright (c) 2013年 tonpe. All rights reserved.
//

#import "DebugFormat.h"

@implementation DebugFormat

static NSDateFormatter *dateFormatter = nil;

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    if(!dateFormatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm:ss:SS"];
        dateFormatter = formatter;
    }
//    NSString *time = [dateFormatter stringFromDate:logMessage.timestamp];
    
	return [NSString stringWithFormat:@"%@ (%@ %lu) \n %@",
			logMessage.timestamp, logMessage.function, (unsigned long)logMessage.line, [self unicodeToChinese:logMessage.message]];
}


- (NSString *)unicodeToChinese:(NSString *)unicode
{
    NSString *tempStr1 = [unicode stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}


@end
