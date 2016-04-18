//
//  AppManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTUser.h"
#import <TMCache.h>
#import "ClientInfo.h"
#import "DeviceInfo.h"
#import "MultiMediaManager.h"
#import "CoreDataManager.h"
#import "NavigationModel.h"
#import "HKTokenPool.h"
#import "HKAddressComponent.h"
#import "HomePicModel.h"

#define Province @"Province"
#define City @"City"
#define District @"District"
#define LastLocationTime @"LastLocationTime"
#define Restriction @"Restriction"
#define Temperature @"Temperature"
#define Temperaturetip @"Temperaturetip"
#define Temperaturepic @"Temperaturepic"
#define LastWeatherTime @"LastWeatherTime"
#define SearchHistory   @"SearchHistory"
#define AddrComonpent   @"AddrComonpent"
#define HomePicKey   @"HomePic_3.0.0"

@interface AppManager : NSObject

@property (nonatomic,strong)JTUser *myUser;
///默认的coredata数据管理对象
@property (nonatomic, strong) CoreDataManager *defDataMgr;
@property (nonatomic, strong) NavigationModel *navModel;
@property (nonatomic,strong, readonly)DeviceInfo * deviceInfo;
@property (nonatomic, strong,readonly) HKTokenPool *tokenPool;
@property (nonatomic,strong)ClientInfo * clientInfo;
///首页九宫格数据结构
@property (nonatomic,strong)HomePicModel * homePicModel;
///常用数据缓存（可手动清除）
@property (nonatomic, strong, readonly) TMCache *dataCache;

@property (nonatomic, strong) MultiMediaManager *mediaMgr;

///评价小标，从1-5星排序
@property (nonatomic,strong)NSArray * commentList;

// 是否需要切换到测试环境，用于Debug模式的正式测试环境切换
@property (nonatomic)BOOL isSwitchToFormalSurrounding;

///全局开放缓存，存有上次的
///省<Province>市<City>区<District> 上次获取地址成功的时间<LastLocationTime>
///限行信息<Restriction> 	 温度范围<Temperature>   提示语<Temperaturetip>   图片名称<Temperaturepic> 上次获取天气成功的时间<LastWeatherTime>@fq TODO 集成到一个model
///首页广告<HomepageAdvertise>,首页图片等
@property (nonatomic, strong, readonly) TMCache *globalInfoCache;

@property (nonatomic)BOOL needRefreshWeather;

@property (nonatomic, strong) HKAddressComponent *addrComponent;
@property (nonatomic,copy)NSString *province;
@property (nonatomic,copy)NSString *city;
@property (nonatomic,copy)NSString *district;

@property (nonatomic,copy)NSString *restriction;
@property (nonatomic,copy)NSString *temperature;
@property (nonatomic,copy)NSString *temperaturetip;
@property (nonatomic,copy)NSString *temperaturepic;

/// 搜索历史
@property (nonatomic,strong)NSArray * searchHistoryArray;

///是否显示分享按钮的标示
@property (nonatomic)BOOL canShareFlag;


+ (AppManager *)sharedManager;

- (void)resetWithAccount:(NSString *)account;

///获取搜索历史
- (NSArray *)loadSearchHistory;
///清除搜索历史
- (void)cleanSearchHistory;
///获取省数组
- (NSArray *)getProvinceArray;
///版本升级
- (void)startUpdatingWithURLString:(NSString *)strurl;
///相关开关设置
- (void)getSwitchConfiguration;
///获取上次首页图片信息
- (HomePicModel *)loadLastHomePicInfo;
///获取上次首页图片信息
- (BOOL)saveHomePicInfo;

///保存元素已读
- (void)saveElementReaded:(NSString *)key;
- (BOOL)getElementReadStatus:(NSString *)key;


- (void)saveInfo:(id <NSCoding>)value forKey:(NSString *)key;
- (NSString *)getInfo:(NSString *)key;

@end
