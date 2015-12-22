//
//  CKDispatcher.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CKEvent;

@interface CKDispatcher : NSNotificationCenter

+ (instancetype)sharedDispatcher;
- (void)sendEvent:(CKEvent *)event;
- (RACSignal *)rac_addObserverForEventName:(NSString *)evtName;

@end
