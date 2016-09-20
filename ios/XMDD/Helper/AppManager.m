//
//  AppManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AppManager.h"

#define kSharedCacheName    @"AppInfoManager_dataCache"

@implementation AppManager

+ (AppManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static AppManager *g_appManager;
    dispatch_once(&onceToken, ^{
        g_appManager = [[AppManager alloc] init];
    });
    return g_appManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // 默认的coredata数据管理对象
        self.defDataMgr = [[CoreDataManager alloc] init];
        [self.defDataMgr resetPersistentStoreAtDirPath:CKPathForDocument(nil)];
        self.navModel = [[NavigationModel alloc] init];
        //  常用数据缓存（用于缓存用户使用造成的数据，可手动清除）
        TMCache *cache = [[TMCache alloc] initWithName:kSharedCacheName];
        cache.diskCache.byteLimit = 512 * 1024 * 1024;
        _dataCache = cache;
        //多媒体管理器
        _mediaMgr = [[MultiMediaManager alloc] init];
        
        cache = [[TMCache alloc] initWithName:@"PromptionCache"];
        cache.diskCache.byteLimit = 200 * 1024 * 1024; // 200M
        _globalInfoCache = cache;
        
        _deviceInfo = [[DeviceInfo alloc] init];
        _clientInfo = [[ClientInfo alloc] init];
        
        _tokenPool = [[HKTokenPool alloc] init];
    }
    return self;
}

- (void)resetWithAccount:(NSString *)account
{
    if (!account)
    {
        self.myUser = nil;
        return;
    }
    JTUser *user = [JTUser new];
    user.userID = account;
    self.myUser = user;
}


#pragma mark - 数据存取
- (NSArray *)loadSearchHistory
{
    self.searchHistoryArray = [self.globalInfoCache objectForKey:SearchHistory];
    return self.searchHistoryArray;
}

- (HomePicModel *)loadLastHomePicInfo
{
    self.homePicModel = [self.globalInfoCache objectForKey:HomePicKey];
    if (!self.homePicModel)
    {
        self.homePicModel = [[HomePicModel alloc] init];
    }
    
    if (!self.homePicModel.homeItemArray.count)
    {
        HomeItem * item1 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=g" imageName:@"hp_refuel_330" isnew:NO];
        HomeItem * item2 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=sl" imageName:@"hp_carwash_330" isnew:NO];
        HomeItem * item3 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=a" imageName:@"hp_weekcoupon_330" isnew:NO];
        HomeItem * item4 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=beautysl" imageName:@"hp_beauty_330" isnew:NO];
        HomeItem * item5 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=mtsl" imageName:@"hp_maintance_330" isnew:NO];
        HomeItem * item6 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=vio" imageName:@"hp_violation_330" isnew:NO];
        HomeItem * item7 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=ins" imageName:@"hp_insurance_330" isnew:NO];
        HomeItem * item8 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=rescue" imageName:@"hp_rescue_330" isnew:NO];
        HomeItem * item9 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=ast" imageName:@"hp_assist_330" isnew:NO];
        HomeItem * item10 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=val" imageName:@"hp_valuation_330" isnew:NO];
        HomeItem * item11 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=nearbyservice&type=3" imageName:@"hp_gasshop_330" isnew:NO];
        HomeItem * item12 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=moresubmodule" imageName:@"hp_more_330" isnew:NO];
        
        
        self.homePicModel.homeItemArray = @[item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12];
    }
    if (!self.homePicModel.moreItemArray.count)
    {
        HomeItem * item1 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=nearbyservice&type=1" imageName:@"hp_parking_330" isnew:NO];
        HomeItem * item2 = [[HomeItem alloc] initWithId:nil titlt:nil picUrl:nil andUrl:@"xmdd://j?t=nearbyservice&type=2" imageName:@"hp_4sshop_330" isnew:NO];

        self.homePicModel.moreItemArray = @[item1,item2];
    }
    return self.homePicModel;
}

- (BOOL)saveHomePicInfo
{
    [self saveInfo:self.homePicModel forKey:HomePicKey];
    return YES;
}

- (void)cleanSearchHistory
{
    [self.globalInfoCache removeObjectForKey:SearchHistory];
}

- (NSArray *)getProvinceArray
{
    NSArray * array = @[@{@"浙":@"(浙江)"},@{@"沪":@"(上海)"},@{@"京":@"(北京)"},
                        @{@"粤":@"(广东)"},@{@"津":@"(天津)"},@{@"苏":@"(江苏)"},
                        @{@"川":@"(四川)"},@{@"辽":@"(辽宁)"},@{@"黑":@"(黑龙江)"},
                        @{@"鲁":@"(山东)"},@{@"湘":@"(湖南)"},
                        @{@"蒙":@"(内蒙古)"},@{@"甘":@"(甘肃)"},@{@"冀":@"(河北)"},
                        @{@"青":@"(青海)"},@{@"新":@"(新疆)"},@{@"陕":@"(陕西)"},
                        @{@"宁":@"(宁夏)"},@{@"皖":@"(安徽)"},@{@"豫":@"(河南)"},
                        @{@"鄂":@"(湖北)"},@{@"晋":@"(山西)"},@{@"渝":@"(重庆)"},
                        @{@"黔":@"(贵州)"},@{@"贵":@"(贵州)"},@{@"桂":@"(广西)"},
                        @{@"藏":@"(西藏)"},@{@"云":@"(云南)"},@{@"赣":@"(江西)"},
                        @{@"吉":@"(吉林)"},@{@"闽":@"(福建)"},@{@"琼":@"(海南)"},
                        @{@"使":@"(大使馆)"}];
    return array;
}

- (void)saveInfo:(id <NSCoding>)value forKey:(NSString *)key
{
    CKAsyncHighQueue(^{
        [self.globalInfoCache setObject:value forKey:key];
    });
}

- (id)getInfo:(NSString *)key
{
    return [self.globalInfoCache objectForKey:key];
}

- (void)saveElementReaded:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
}

- (BOOL)getElementReadStatus:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (BOOL)loadLastMutualPlanTabAppear
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:AppMutualPlanAppear];
}

- (void)saveMutualPlanTabAppear:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AppMutualPlanAppear];
}



#pragma mark - 升级相关
- (void)startUpdatingWithURLString:(NSString *)strurl
{
    if (strurl.length == 0)
    {
        strurl = @"";
    }
    NSString * newUrl = [strurl stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL *url = [NSURL URLWithString:newUrl];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        DebugLog(@"can not update client version with url:%@", strurl);
    }
}

@end
