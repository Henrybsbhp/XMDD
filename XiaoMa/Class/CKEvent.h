//
//  CKEvent.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKEvent : NSObject
@property (nonatomic, strong, readonly) RACSignal *signal;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) id object;
@property (nonatomic, strong, readonly) NSDictionary *userInfo;

+ (CKEvent *)eventWithName:(NSString *)aName signal:(RACSignal *)signal;
+ (CKEvent *)eventWithName:(NSString *)aName object:(id)object signal:(RACSignal *)signal;
+ (CKEvent *)eventWithName:(NSString *)aName object:(id)object userInfo:(NSDictionary *)userInfo signal:(RACSignal *)signal;
- (CKEvent *)mapSignal:(RACSignal *(^)(RACSignal *signal))block;

- (RACSignal *)send;
- (RACSignal *)sendAndIgnoreError;
- (RACSignal *)sendWithIgnoreError:(BOOL)ignore andDelay:(NSTimeInterval)delay;

- (CKEvent *)setObject:(id)object;
- (CKEvent *)setUserInfo:(NSDictionary *)userInfo;

- (BOOL)isEqualForName:(NSString *)name;
- (BOOL)isEqualForAnyoneOfNames:(NSArray *)names;

@end

@interface RACSignal (CKEvent)
- (CKEvent *)eventWithName:(NSString *)aName;
- (CKEvent *)eventWithName:(NSString *)aName object:(id)object;
- (CKEvent *)eventWithName:(NSString *)aName object:(id)object userInfo:(NSDictionary *)userInfo;
@end