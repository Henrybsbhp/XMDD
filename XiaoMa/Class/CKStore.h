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


@interface CKStore : NSObject
@property (nonatomic, strong) JTQueue *cache;

+ (instancetype)fetchExistsStore;
+ (instancetype)fetchOrCreateStore;
- (void)subscribeEventsWithTarget:(id)target receiver:(void(^)(CKStore *store, RACSignal *evt, NSInteger code))block;
+ (void)sendEvent:(RACSignal *)event withCode:(NSInteger)code;
- (void)sendEvent:(RACSignal *)event withCode:(NSInteger)code;

@end
