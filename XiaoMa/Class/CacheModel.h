//
//  CacheModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheModel : NSObject
@property (nonatomic, readonly) id cache;
///(default is 60*60)
@property (nonatomic, assign) NSTimeInterval updateInterval;

#pragma mark - Private
///@override（子类中必须实现该方法）
- (RACSignal *)rac_requestData;

#pragma mark - Public
- (void)removeAllObservers;
- (RACSignal *)rac_observeDataWithDoRequest:(void(^)(void))block;
- (RACSignal *)rac_fetchData;
- (RACSignal *)rac_fetchDataIfNeeded;
- (id)updateCache:(id)newCache refreshTime:(BOOL)refresh;

@end
