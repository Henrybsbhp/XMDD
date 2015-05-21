//
//  AppManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTUser.h"
#import "TMCache.h"
#import "ClientInfo.h"
#import "DeviceInfo.h"
#import "MultiMediaManager.h"
#import "CoreDataManager.h"

#define Province @"Province"
#define City @"City"
#define District @"District"
#define LastLocationTime @"LastLocationTime"
#define Restriction @"Restriction"
#define Temperature @"Temperature"
#define Temperaturetip @"Temperaturetip"
#define Temperaturepic @"Temperaturepic"
#define LastWeatherTime @"LastWeatherTime"
#define HomepageAdvertise @"HomepageAdvertise"
#define SearchHistory   @"SearchHistory"

@interface AppManager : NSObject

@property (nonatomic,strong)JTUser *myUser;
///当前用户的coredata数据管理对象
@property (nonatomic, strong) CoreDataManager *myDataMgr;
///默认的coredata数据管理对象
@property (nonatomic, strong) CoreDataManager *defDataMgr;
@property(nonatomic,strong)DeviceInfo * deviceInfo;
@property(nonatomic,strong)ClientInfo * clientInfo;
///常用数据缓存（可手动清除）
@property (nonatomic, strong, readonly) TMCache *dataCache;
@property (nonatomic, strong) MultiMediaManager *mediaMgr;

+ (AppManager *)sharedManager;

- (void)resetWithAccount:(NSString *)account;

///全局开放缓存，存有上次的
///省<Province>市<City>区<District> 上次获取地址成功的时间<LastLocationTime>
///限行信息<Restriction> 	 温度范围<Temperature>   提示语<Temperaturetip>   图片名称<Temperaturepic> 上次获取天气成功的时间<LastWeatherTime>
///首页广告<HomepageAdvertise>
@property (nonatomic, strong, readonly) TMCache *promptionCache;

@property (nonatomic)BOOL needRefreshWeather;

@property (nonatomic,copy)NSString *province;
@property (nonatomic,copy)NSString *city;
@property (nonatomic,copy)NSString *district;

@property (nonatomic,copy)NSString *restriction;
@property (nonatomic,copy)NSString *temperature;
@property (nonatomic,copy)NSString *temperaturetip;
@property (nonatomic,copy)NSString *temperaturepic;

@property (nonatomic,strong)NSArray * homepageAdvertiseArray;

@property (nonatomic,strong)NSArray * searchHistoryArray;



///获取上次的定位地址和天气信息
- (void)loadLastLocationAndWeather;
///获取上次的广告信息
- (NSArray *)loadLastAdvertiseInfo;
///获取搜索历史
- (NSArray *)loadSearchHistory;
- (void)cleanSearchHistory;


- (void)saveInfo:(id <NSCoding>)value forKey:(NSString *)key;

- (NSString *)getInfo:(NSString *)key;


///版本升级
- (void)startUpdatingWithURLString:(NSString *)strurl;
@end
