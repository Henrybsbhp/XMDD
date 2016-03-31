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
@synthesize addrComponent = _addrComponent;

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

#pragma mark - Setter And Getter
- (void)setAddrComponent:(HKAddressComponent *)addrComponent
{
    _addrComponent = addrComponent;
    [self.globalInfoCache setObject:addrComponent forKey:@"addrComponent"];
}

- (HKAddressComponent *)addrComponent
{
    if (!_addrComponent) {
        _addrComponent = [self.globalInfoCache objectForKey:@"addrComponent"];
    }
    return _addrComponent;
}

#pragma mark - 数据存取
- (void)loadLastLocationAndWeather
{
    self.city = [self getInfo:City];
    self.district = [self getInfo:District];
    self.temperature = [self getInfo:Temperature];
    self.temperaturepic = [self getInfo:Temperaturepic];
    self.temperaturetip = [self getInfo:Temperaturetip];
    self.restriction = [self getInfo:Restriction];
}

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
        HomeItem * item1 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=g" imageName:@"hp_refuel_300"];
        HomeItem * item2 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=sl" imageName:@"hp_carwash_300"];
        HomeItem * item3 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=coins" imageName:@"hp_mutualIns_300"];
        HomeItem * item4 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=ins" imageName:@"hp_insurance_300"];
        HomeItem * item5 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=vio" imageName:@"hp_ peccancy_300"];
        HomeItem * item6 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=val" imageName:@"hp_valuation_300"];
        HomeItem * item7 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=rescue" imageName:@"hp_rescue_300"];
        HomeItem * item8 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=ast" imageName:@"hp_assist_300"];
        HomeItem * item9 = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=more" imageName:@"hp_more_300"];
        self.homePicModel.homeItemArray = @[item1,item2,item3,item4,item5,item6,item7,item8,item9];
    }
    
    if (!self.homePicModel.bottomItem)
    {
        self.homePicModel.bottomItem = [[HomeItem alloc] initWithTitlt:nil picUrl:nil andUrl:@"xmdd://j?t=a" imageName:@"hp_award_300"];
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

- (void)getSwitchConfiguration
{
    
}
@end
