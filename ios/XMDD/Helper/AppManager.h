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
#import "HKTabBarVC.h"

#define LastLocationTime @"LastLocationTime"
#define SearchHistory   @"SearchHistory"
#define AddrComonpent   @"AddrComonpent"
#define HomePicKey   @"HomePic_3.0.0"
#define AppMutualPlanAppear @"k.xmdd.appMutualPlanTabAppear"
#define AppMutualPlanDot @"k.xmdd.appMutualPlanDot"

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
///美容评价小标，从1-5星排序
@property (nonatomic,strong)NSArray * beautycommentList;
///保养评价小标，从1-5星排序
@property (nonatomic,strong)NSArray * maintenancecommentList;

// 是否需要切换到测试环境，用于Debug模式的正式测试环境切换
@property (nonatomic)BOOL isSwitchToFormalSurrounding;

///全局开放缓存，存有上次的 首页广告<HomepageAdvertise>,首页信息等
@property (nonatomic, strong, readonly) TMCache *globalInfoCache;

@property (nonatomic)BOOL needRefreshWeather;

///限行信息
@property (nonatomic,copy)NSString *restriction;
///温度
@property (nonatomic,copy)NSString *temperatureAndTip;
/// 天气icon
@property (nonatomic,copy)NSString *temperaturepic;

/// 搜索历史
@property (nonatomic,strong)NSArray * searchHistoryArray;

///是否显示分享按钮的标示
@property (nonatomic)BOOL canShareFlag;

// 互助tab相关信息
/// 互助tab是否展示
@property (nonatomic)BOOL huzhuTabFlag;
/// 互助tab顶部信息
@property (nonatomic,copy)NSString * huzhuTabTitle;
/// 互助tab顶部提示url
@property (nonatomic,copy)NSString * huzhuTabUrl;
@property (nonatomic,strong)HKTabBarVC * tabBarVC;


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
///获取上次首页图片信息
- (HomePicModel *)loadLastHomePicInfo;
///保存上次首页图片信息
- (BOOL)saveHomePicInfo;
///获取上次互助计划tab是否展示;
- (BOOL)loadLastMutualPlanTabAppear;
///保存上次互助计划tab是否展示
- (void)saveMutualPlanTabAppear:(BOOL)flag;

///保存元素已读
- (void)saveElementReaded:(NSString *)key;
- (BOOL)getElementReadStatus:(NSString *)key;


- (void)saveInfo:(id <NSCoding>)value forKey:(NSString *)key;
- (NSString *)getInfo:(NSString *)key;

@end
