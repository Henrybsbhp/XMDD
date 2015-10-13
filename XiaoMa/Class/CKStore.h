//
//  CKBaseModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    kCKStoreEventUnknow = 0,
    kCKStoreEventReload,
    kCKStoreEventGet,
    kCKStoreEventAdd,
    kCKStoreEventDelete,
    kCKStoreEventUpdate
}CKStoreEventCode;

@class CKStoreEvent;
@interface CKStore : NSObject
@property (nonatomic, strong) JTQueue *cache;
///default is 60*60 seconds;
@property (nonatomic, assign) NSTimeInterval updateDuration;

+ (instancetype)fetchExistsStore;
+ (instancetype)fetchOrCreateStore;
- (void)subscribeEventsWithTarget:(id)target receiver:(void(^)(CKStore *store, CKStoreEvent *evt))block;
+ (CKStoreEvent *)sendEvent:(CKStoreEvent *)evt;
- (CKStoreEvent *)sendEvent:(CKStoreEvent *)evt;

- (BOOL)needUpdateTimetag;
- (void)updateTimetag;

@end

@interface CKStoreEvent : NSObject
@property (nonatomic, assign, readonly) NSInteger code;
@property (nonatomic, strong, readonly) RACSignal *signal;
@property (nonatomic, strong) id object;

+ (instancetype)eventWithSignal:(RACSignal *)sig code:(NSInteger)code object:(id)obj;
- (CKStoreEvent *)setSignal:(RACSignal *)signal;

@end

