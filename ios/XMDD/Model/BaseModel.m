//
//  BaseModel.m
//  HappyTrain
//
//  Created by icopy on 14/12/27.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "BaseModel.h"

@interface BaseModel()

/// 真正的data发送信号
@property (nonatomic) RACSubject * internalDataSignal;

/// 标注是否需要更新
@property (nonatomic) BOOL needsUpdate;

/// 标注最近一次
@property (nonatomic) NSUInteger lastUpdateAttempTime;

/// 用于子类继承，并请求数据
- (RACSignal *) rac_requestData;

@end


@implementation BaseModel

- (id) init
{
    self = [super init];
    if(self)
    {
        // 默认设置1天后更新
        self.updateInterval = 24 * 3600;
        
        // 将上次更新时间设置为0
        _lastUpdateTime = 0;
        
        // 刚生成，肯定需要更新数据
        self.needsUpdate = YES;
        
        // 初始化内部dataSignal
        self.internalDataSignal = [RACReplaySubject replaySubjectWithCapacity:1];
    }
    return self;
}

/// 如果需要，刷新Model
- (RACSignal *) rac_updateModelIfNeeded
{
    if (([[NSDate date] timeIntervalSince1970]- self.lastUpdateTime - self.updateInterval) > 0
        || self.needsUpdate) {
        DebugLog(@"%@ needs update!", self);
        self.needsUpdate = NO;
        return [self rac_updateModel];
    }else{
        return [RACSignal empty];
    }
}

/// 如果需要，异步刷新Model
- (void) updateModelIfNeeded
{
    [[self rac_updateModelIfNeeded] subscribeNext:^(id x) {
        // 什么都不做，仅触发一下信号
    }];
}

/// 设置是否需要刷新model
- (void) setNeedUpdateModel
{
    self.needsUpdate = YES;
}

- (RACSignal *) rac_updateModel
{
    if (!self.enable) {
        [self updateModelWithData:nil];
        return [RACSignal empty];
    }
    NSUInteger now = [[NSDate date] timeIntervalSince1970];
    
    self.lastUpdateAttempTime = now;
    
    return [[self rac_requestData] doNext:^(id newData) {

        // 更新成功后，将数据缓存设置为
        [self.internalDataSignal sendNext:newData];
        _lastUpdateTime = [[NSDate date] timeIntervalSince1970];
    }]; // 错误处理交给底层的Model，有些error可能是业务层面的，因此不在BaseModel里面做处理。
}

- (void) updateModel
{
    [[self rac_updateModel] subscribeNext:^(id x) {
        // do nothing
    }];
}

- (void) resetData
{
    [self updateModelWithData:nil];
    _lastUpdateTime = 0;
    _lastUpdateAttempTime = 0;
}

- (void) updateModelWithData: (id) newData
{
    [self.internalDataSignal sendNext:newData];
}

- (RACSignal *)getDataSignal
{
    return self.internalDataSignal;
}

- (RACSignal *) rac_requestData
{
    return [RACSignal empty];
}


@end
