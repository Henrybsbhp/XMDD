//
//  AdvertisementManager.h
//  XiaoMa
//
//  Created by jt on 15-5-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

#define HomepageAdvertise @"HomepageAdvertise"
#define CarwashAdvertise @"CarwashAdvertise"

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

@end
