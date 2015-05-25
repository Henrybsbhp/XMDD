//
//  AdvertisementManager.h
//  XiaoMa
//
//  Created by jt on 15-5-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

#define CarwashAdvertiseNotification @"CarwashAdvertiseNotification"

@interface AdvertisementManager : NSObject

/// 首页广告
@property (nonatomic,strong)NSArray * homepageAdvertiseArray;
/// 洗车页面广告
@property (nonatomic,strong)NSArray * carwashAdvertiseArray;

+ (AdvertisementManager *)sharedManager;

///获取上次的广告信息
- (NSArray *)loadLastAdvertiseInfo:(AdvertisementType)type;

- (RACSignal *)rac_getAdvertisement:(AdvertisementType)type;

///获取广告信息，如果未超过更新时间，直接从缓存里获取；否则将先返回缓存中的广告，再获取返回从网络下载过来的广告
- (RACSignal *)rac_fetchAdListByType:(AdvertisementType)type;

- (RACSignal *)rac_scrollTimerSignal;
@end
