//
//  DebugFormat.h
//  ZJUMobile
//
//  Created by cyclist on 13-9-8.
//  Copyright (c) 2013年 tonpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack.h>

#ifdef DEBUG
#define DebugLog DDLogVerbose
#define DebugGreenLog DDLogDebug
#define DebugInfoLog DDLogInfo
#define DebugWarningLog DDLogWarn
#define DebugErrorLog DDLogError
#else
#define DebugLog(frmt, ...)
#define DebugGreenLog(frmt, ...)
#define DebugInfoLog(frmt, ...)
#define DebugWarningLog(frmt, ...)
#define DebugErrorLog(frmt, ...)
#endif



#ifdef __OBJC__
#ifdef DEBUG
#define HKCLSLog(__FORMAT__, ...) CLSNSLog((__FORMAT__),##__VA_ARGS__)
#else
#define HKCLSLog(__FORMAT__, ...) CLSLog((@"%s line %d $ " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif
#endif

static int ddLogLevel = DDLogLevelVerbose;

@interface DebugFormat : NSObject<DDLogFormatter>

@end
