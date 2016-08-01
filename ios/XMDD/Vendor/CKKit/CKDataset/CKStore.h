//
//  CKStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKEvent.h"

@class CKStore;

@protocol CKStoreDelegate <NSObject>

+ (instancetype)fetchExistsStore;
+ (instancetype)fetchOrCreateStore;
///observe方法用于在Store内部监听事件
- (CKEvent *)inlineEvent:(CKEvent *)event;
- (CKEvent *)inlineEvent:(CKEvent *)event forDomain:(NSString *)domain;
- (CKEvent *)inlineEvent:(CKEvent *)event forDomainList:(NSArray *)domains;
- (CKEvent *)inlineEvent:(CKEvent *)event handler:(void(^)(CKEvent *))handler;
///trigger方法用于对外触发经过Store处理的事件
- (void)triggerEvent:(CKEvent *)event;
- (void)triggerEvent:(CKEvent *)event forDomain:(NSString *)domain;
- (void)triggerEvent:(CKEvent *)event forDomainList:(NSArray *)domains;
///subscribe用于外部监听事件的发生
- (void)subscribeWithTarget:(id)target domain:(NSString *)domain receiver:(void(^)(id store, CKEvent*evt))block;
- (void)subscribeWithTarget:(id)target domainList:(NSArray *)domains receiver:(void(^)(id store, CKEvent*evt))block;
- (RACSignal *)rac_subscribeWithTarget:(id)target domainList:(NSArray *)domains;
- (RACSignal *)rac_subscribeWithTarget:(id)target domain:(NSString *)domain;

@end

@interface CKStore : NSObject <CKStoreDelegate>

+ (instancetype)fetchExistsStoreForWeakKey:(id)key;
+ (instancetype)fetchOrCreateStoreForWeakKey:(id)key;

@end

