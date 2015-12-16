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
- (void)observeEventForName:(NSString *)name selector:(SEL)selector;
- (void)observeEventForName:(NSString *)name handler:(void(^)(CKEvent *))handler;
- (CKEvent *)inlineEvent:(CKEvent *)event;
- (CKEvent *)inlineEvent:(CKEvent *)event forDomain:(NSString *)domain;
///trigger方法用于对外触发经过Store处理的事件
- (void)triggerEvent:(CKEvent *)event;
- (void)triggerEvent:(CKEvent *)event forDomain:(NSString *)domain;
- (void)subscribeWithTarget:(id)target domain:(NSString *)domain receiver:(void(^)(CKStore *store, CKEvent*evt))block;

@end

@interface CKStore : NSObject <CKStoreDelegate>

+ (instancetype)fetchExistsStoreForWeakKey:(id)key;
+ (instancetype)fetchOrCreateStoreForWeakKey:(id)key;

@end

