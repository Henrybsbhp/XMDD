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
        _mediaMgr = [[MultiMediaManager alloc] initWithPicCache:_dataCache];
        
        cache = [[TMCache alloc] initWithName:@"PromptionCache"];
        cache.diskCache.byteLimit = 200 * 1024 * 1024; // 200M
        _promptionCache = cache;
        
        _deviceInfo = [[DeviceInfo alloc] init];
        _clientInfo = [[ClientInfo alloc] init];
    }
    return self;
}

- (void)resetWithAccount:(NSString *)account
{
    [self.myUser.carModel removeAllObservers];
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
- (void)loadLastLocationAndWeather
{
    self.province = [self getInfo:Province];
    self.city = [self getInfo:City];
    self.district = [self getInfo:District];
    self.temperature = [self getInfo:Temperature];
    self.temperaturepic = [self getInfo:Temperaturepic];
    self.temperaturetip = [self getInfo:Temperaturetip];
    self.restriction = [self getInfo:Restriction];
}


- (NSArray *)loadSearchHistory
{
    self.searchHistoryArray = [self.promptionCache objectForKey:SearchHistory];
    return self.searchHistoryArray;
}

- (void)cleanSearchHistory
{
    [self.promptionCache removeObjectForKey:SearchHistory];
}

- (void)saveInfo:(id <NSCoding>)value forKey:(NSString *)key
{
    CKAsyncHighQueue(^{
        [self.promptionCache setObject:value forKey:key];
    });
}

- (NSString *)getInfo:(NSString *)key
{
//    if (!key.length)
//    {
//        return nil;
//    }
//    __block NSString * value = nil;
//    
//    static dispatch_queue_t queue;
//    static dispatch_once_t predicate;
//    
//    dispatch_once(&predicate, ^{
//        queue = dispatch_queue_create("aaaaaaaaaaa", DISPATCH_QUEUE_SERIAL);
//    });
//    
//    
//    dispatch_sync(queue, ^{
//        value = [self.promptionCache objectForKey:key];
//    });
//    
//    return value;

//    __block NSString * value;
//    CKAsyncHighQueue(^{
        return [self.promptionCache objectForKey:key];
//    });
//    return value;
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
