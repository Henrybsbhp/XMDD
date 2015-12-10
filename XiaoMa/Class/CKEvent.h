//
//  CKEvent.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKEvent : NSNotification
@property (nonatomic, strong, readonly) RACSignal *signal;

+ (CKEvent *)eventWithName:(NSString *)aName signal:(RACSignal *)signal;
+ (CKEvent *)eventWithName:(NSString *)aName object:(id)object signal:(RACSignal *)signal;
+ (CKEvent *)eventWithName:(NSString *)aName object:(id)object userInfo:(NSDictionary *)userInfo signal:(RACSignal *)signal;
+ (NSString *)wholeEventName:(NSString *)name;
- (CKEvent *)mapSignal:(RACSignal *(^)(RACSignal *signal))block;
- (RACSignal *)send;

@end

@interface RACSignal (CKEvent)
- (CKEvent *)eventWithName:(NSString *)aName;
- (CKEvent *)eventWithName:(NSString *)aName object:(id)object;
- (CKEvent *)eventWithName:(NSString *)aName object:(id)object userInfo:(NSDictionary *)userInfo;
@end