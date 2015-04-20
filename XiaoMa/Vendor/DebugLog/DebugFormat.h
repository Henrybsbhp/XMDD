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
#else
#define DebugLog(frmt, ...)
#endif
static int ddLogLevel = DDLogLevelVerbose;

@interface DebugFormat : NSObject<DDLogFormatter>

@end
