//
//  AppManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AppManager.h"

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
        TMCache *cache = [[TMCache alloc] initWithName:@"PromptionCache"];
        cache.diskCache.byteLimit = 200 * 1024 * 1024; // 200M
        _promptionCache = cache;
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
//    //TODO:临时数据
//    user.userID = @"123456";
//    user.userName = @"陈大白";
//    user.avatarUrl = @"tmp_a1";
//    user.carwashTicketsCount = 2;
//    user.abcCarwashTimesCount = 4;
//    user.abcIntegral = 40000;
//    user.numberPlate = @"浙A12345";
    self.myUser = user;
}

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

- (NSArray *)loadLastAdvertiseInfo
{
    self.homepageAdvertiseArray = [self.promptionCache objectForKey:HomepageAdvertise];
    return self.homepageAdvertiseArray;
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
//    __block NSString * value;
//    CKAsyncHighQueue(^{
        return [self.promptionCache objectForKey:key];
//    });
//    return value;
}


- (void)startUpdatingWithURLString:(NSString *)strurl
{
    if (strurl.length == 0)
    {
        strurl = @"";
    }
    NSURL *url = [NSURL URLWithString:strurl];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
//        DebugLog(@"can not update client version with url:%@", strurl);
    }
}
@end
