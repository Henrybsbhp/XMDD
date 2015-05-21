//
//  BaseModel.h
//  HappyTrain
//
//  Created by icopy on 14/12/27.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

//
//  这是所有数据Model的基础类，所有的子类都可以继承BaseModel.
//  BaseModel有两种类型的操作：
//  一是刷新，包括rac_updateModel，rac_updateModelIfNeeded；
//  二是订阅数据，了解数据的最新变化。
//
//  BaseModel可控制数据刷新的频率，将最新数据放置在内存中。
//  以后将考虑将缓存数据放置在数据库中。
//
//  子类可以通过updateBlock和didReceiveNewData对数据进行处理。
//
//  This is only the Begining.
//

#import <Foundation/Foundation.h>

#define kMinimumAttempInterval 2000

@interface BaseModel : NSObject

#pragma 数据信号和属性
/// View或其他VC订阅该信号，获取更新
@property (nonatomic, strong, readonly, getter=getDataSignal) RACSignal * dataSignal;

/// lazy数据刷新的时间间隔，以毫秒计算
@property (nonatomic) NSInteger updateInterval;

/// 标注最后成功更新的时间
@property (nonatomic, readonly) NSUInteger lastUpdateTime;

/// resetSignal一旦发射，整个Model就会被重置，发送的数据也为nil。用户账号登出等操作。
//  注意：reset功能还未实现！！！
@property (nonatomic, strong) RACSignal * restSignal;

/// 此属性控制当前模型是否启用，如果设为NO，所有数据均输出nil。
@property (nonatomic) BOOL enable;


#pragma 数据更新方法
/// 强制刷新model
- (RACSignal *) rac_updateModel;

/// 异步强制刷新model，不返回Signal
- (void) updateModel;

/// 刷新model
- (RACSignal *) rac_updateModelIfNeeded;

/// 异步刷新model，不返回Signal
- (void) updateModelIfNeeded;

/// 设置是否需要刷新model
- (void) setNeedUpdateModel;

/// 本地更新数据
- (void) updateModelWithData: (id) newData;

/// 清空本地数据，注意，从子类往父类调用
- (void) resetData;

@end
