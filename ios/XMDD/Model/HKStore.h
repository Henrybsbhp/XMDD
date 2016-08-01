//
//  CKBaseModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    kHKStoreEventUnknow = 0,
    kHKStoreEventReload,
    kHKStoreEventNone,
    kHKStoreEventGet,
    kHKStoreEventAdd,
    kHKStoreEventDelete,
    kHKStoreEventUpdate,
    kHKStoreEventSelect
}HKStoreEventCode;

@class HKStoreEvent;
@interface HKStore : NSObject
@property (nonatomic, strong) JTQueue *cache;
///default is 60*60 seconds;
@property (nonatomic, assign) NSTimeInterval updateDuration;

+ (instancetype)fetchExistsStore;
+ (instancetype)fetchOrCreateStore;
+ (instancetype)fetchExistsStoreForWeakKey:(id)key;
+ (instancetype)fetchOrCreateStoreForWeakKey:(id)key;
+ (instancetype)merge:(id<NSFastEnumeration>)stores;
- (instancetype)merge:(id<NSFastEnumeration>)store;
- (void)subscribeEventsWithTarget:(id)target receiver:(void(^)(HKStore *store, HKStoreEvent *evt))block;
- (void)removeSubscriptionForTarget:(id)target;
+ (HKStoreEvent *)sendEvent:(HKStoreEvent *)evt;
- (HKStoreEvent *)sendEvent:(HKStoreEvent *)evt;

///(if key is nil, then the inner key is "$DefTimetag")
- (BOOL)needUpdateTimetagForKey:(NSString *)key;
- (void)updateTimetagForKey:(NSString *)key;
- (void)resetAllTimetags;

@end

@interface HKStoreEvent : NSObject
@property (nonatomic, assign, readonly) NSInteger code;
@property (nonatomic, strong, readonly) NSString *identify;
@property (nonatomic, strong, readonly) RACSignal *signal;
@property (nonatomic, strong) id object;

+ (instancetype)eventWithIdentify:(NSString *)identify object:(id)object signal:(RACSignal *)sig;
+ (instancetype)eventWithSignal:(RACSignal *)sig code:(NSInteger)code object:(id)obj;
- (HKStoreEvent *)setSignal:(RACSignal *)signal;
- (BOOL)callIfNeededExceptCode:(NSInteger)code object:(id)obj target:(id)target selector:(SEL)selector;
- (BOOL)callIfNeededExceptCodeList:(NSArray *)codes object:(id)obj target:(id)target selector:(SEL)selector;
- (BOOL)callIfNeededForCode:(NSInteger)code object:(id)obj target:(id)target selector:(SEL)selector;
- (BOOL)callIfNeededForCodeList:(NSArray *)codes object:(id)obj target:(id)target selector:(SEL)selector;
- (BOOL)callIfNeededExceptCode:(NSInteger)code object:(id)obj handler:(void(^)(HKStoreEvent *))handler;
- (BOOL)callIfNeededExceptCodeList:(NSArray *)codes object:(id)obj handler:(void(^)(HKStoreEvent *))handler;
- (BOOL)callIfNeededForCode:(NSInteger)code object:(id)obj handler:(void(^)(HKStoreEvent *))handler;
- (BOOL)callIfNeededForCodeList:(NSArray *)codes object:(id)obj handler:(void(^)(HKStoreEvent *))handler;

@end
