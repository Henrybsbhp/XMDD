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

@protocol CKStoreDelegate <NSObject>

@optional
- (void)reloadData;
@end

@interface CKStore : NSObject <CKStoreDelegate>
+ (instancetype)fetchStore;
+ (void)reloadData;
- (void)subscribeEventsWithTarget:(id)target receiver:(void(^)(RACSignal *event, NSInteger code))block;
- (void)sendEvent:(RACSignal *)event withCode:(NSInteger)code;

@end
