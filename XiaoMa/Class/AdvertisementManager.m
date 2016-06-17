//
//  AdvertisementManager.m
//  XiaoMa
//
//  Created by jt on 15-5-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AdvertisementManager.h"
#import "GetSystemPromotionOp.h"

#define HomepageAdvertise @"HomepageAdvertise"
#define CarwashAdvertise @"CarwashAdvertise"
#define InsuranceAdvertise @"InsuranceAdvertise"

///每12小时更新广告内容
#define kUpdateAdTimeInterval     10
///每5秒钟滚动广告
#define kScrollAdTimeInterval       5

@interface AdvertisementManager()

@property (nonatomic, strong, readonly) TMCache *adCache;
@property (nonatomic, strong) NSMutableDictionary *adInfo;
@property (nonatomic, strong) RACSignal *defScrollTimerSignal;
@end

@implementation AdvertisementManager

+ (AdvertisementManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static AdvertisementManager *g_adManager;
    dispatch_once(&onceToken, ^{
        g_adManager = [[AdvertisementManager alloc] init];
    });
    return g_adManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //  常用数据缓存（用于缓存用户使用造成的数据，可手动清除）
        TMCache *cache = [[TMCache alloc] initWithName:@"AdvertisementCache"];
        cache.diskCache.byteLimit = 200 * 1024 * 1024; // 200M
        _adCache = cache;
        _adInfo = [NSMutableDictionary dictionary];
    }
    return self;
}


- (RACSignal *)rac_getAdvertisement:(AdvertisementType)type
{
    RACSignal * signal = [RACSignal empty];
    //没有地理位置信息，则获取地理位置信息
    if (!gMapHelper.addrComponent) {
        signal = [[gMapHelper rac_getInvertGeoInfo] ignoreError];
    }
    //请求广告信息
    signal = [signal then:^RACSignal *{
        GetSystemPromotionOp * op = [GetSystemPromotionOp operation];
        op.type = type;
        op.province = gMapHelper.addrComponent.province;
        //如果地理位置在上海，高德返回“上海” “（空字符）”“松江”
        op.city = gMapHelper.addrComponent.city.length ? gMapHelper.addrComponent.city :gMapHelper.addrComponent.province;
        op.district = gMapHelper.addrComponent.district;
        op.version = gAppMgr.clientInfo.clientVersion;
        return [op rac_postRequest];
    }];
    
    //处理广告返回结果
    signal = [signal map:^id(GetSystemPromotionOp *op) {
        
        NSString *key = [self keyForAdType:type];
        NSArray *sortedArray = [self filterAndSortAdList:op.rsp_advertisementArray];
        [self saveInfo:op.rsp_advertisementArray forKey:key];
        [self.adInfo setObject:@([[NSDate date] timeIntervalSince1970]) forKey:key];
        NSString *addrKey = [key append:@"_addrComponent"];
        [self.adInfo safetySetObject:gMapHelper.addrComponent forKey:addrKey];
        
        if (type == AdvertisementHomePage)
        {
            self.homepageAdvertiseArray = sortedArray;
        }
        else if (type == AdvertisementCarWash)
        {
            self.carwashAdvertiseArray = sortedArray;
        }
        
        return sortedArray;
    }];
    return signal;
}

- (NSArray *)loadLastAdvertiseInfo:(AdvertisementType)type
{
    NSString * key = [self keyForAdType:type];
    NSArray * array = [self.adCache objectForKey:key];
    NSArray *sortedArray = [self filterAndSortAdList:array];
    if (type == AdvertisementHomePage)
    {
        self.homepageAdvertiseArray = sortedArray;
    }
    else if (type == AdvertisementCarWash)
    {
        self.carwashAdvertiseArray = sortedArray;
    }
    return array;
}

- (RACSignal *)rac_fetchAdListByType:(AdvertisementType)type
{
    NSString *key = [self keyForAdType:type];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSArray *ads = [self.adCache objectForKey:key];
        [subscriber sendNext:[self filterAndSortAdList:ads]];
        [subscriber sendCompleted];
        return nil;
    }];
    
    NSTimeInterval timetag = [(NSNumber *)[self.adInfo objectForKey:key] doubleValue];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    //超过时间间隔,则更新该广告信息
    if (timetag+kUpdateAdTimeInterval < now) {
        signal = [signal concat:[self rac_getAdvertisement:type]];
    }
    else {
        HKAddressComponent *ac = [self.adInfo objectForKey:[key append:@"_addrComponent"]];
        if (![HKAddressComponent isEqualAddrComponent:ac otherAddrComponent:gMapHelper.addrComponent]) {
            signal = [signal concat:[self rac_getAdvertisement:type]];
        }
    }
    
    return signal;
}

- (RACSignal *)rac_scrollTimerSignal
{
    if (!self.defScrollTimerSignal) {
        self.defScrollTimerSignal = [[RACSignal interval:kScrollAdTimeInterval onScheduler:[RACScheduler scheduler]]
                                     deliverOn:[RACScheduler mainThreadScheduler]];
    }
    return self.defScrollTimerSignal;
}

- (void)checkUpdatingByType:(AdvertisementType)type
{
    [[self rac_fetchAdListByType:type] subscribeNext:^(NSArray *adlist) {
        for (HKAdvertisement *ad in adlist) {
            NSString *adurl = [gMediaMgr urlWith:ad.adPic imageType:ImageURLTypeMedium];
            BOOL cached = [gMediaMgr cachedImageExistsForUrl:adurl];
            if (!cached) {
                [[gMediaMgr rac_getImageByUrl:ad.adPic withType:ImageURLTypeMedium defaultPic:nil errorPic:nil] subscribeNext:^(id x) {
                    
                }];
            }
        }
    }];
}

#pragma mark - Utility
- (NSArray *)filterAndSortAdList:(NSArray *)ads
{
    NSArray * filterArray = [ads arrayByFilteringOperator:^BOOL(HKAdvertisement * ad) {
        
        return [NSDate isDateValidWithBegin:ad.validStart andEnd:ad.validEnd];
    }];
    
    NSArray * sortedArray = [filterArray sortedArrayUsingComparator:^NSComparisonResult(HKAdvertisement * ad1, HKAdvertisement * ad2) {
        
        return ad1.weight > ad2.weight ? NSOrderedAscending : (ad1.weight == ad2.weight ? NSOrderedSame : NSOrderedDescending);
    }];
    return sortedArray;
}

- (NSString *)keyForAdType:(AdvertisementType)type
{
    return [NSString stringWithFormat:@"com.huike.xmdd.ad.type.%d", (int)type];
}

#pragma mark - 数据存取

- (void)saveInfo:(id <NSCoding>)value forKey:(NSString *)key
{
    CKAsyncHighQueue(^{
        [self.adCache setObject:value forKey:key];
    });
}

@end
