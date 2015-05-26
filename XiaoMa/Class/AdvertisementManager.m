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
#define kUpdateAdTimeInterval       60*60*12
///每5秒钟滚动广告
#define kScrollAdTimeInterval       5

@interface AdvertisementManager()

@property (nonatomic, strong, readonly) TMCache *adCache;
@property (nonatomic, strong) NSMutableDictionary *timeInfo;
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
        _timeInfo = [NSMutableDictionary dictionary];
    }
    return self;
}


- (RACSignal *)rac_getAdvertisement:(AdvertisementType)type
{
    RACSignal * signal;
    GetSystemPromotionOp * op = [GetSystemPromotionOp operation];
    op.type = type;
    signal = [[op rac_postRequest] map:^id(GetSystemPromotionOp *op) {
        
        NSString *key = [self keyForAdType:type];
        NSArray *sortedArray = [self filterAndSortAdList:op.rsp_advertisementArray];
        [self saveInfo:op.rsp_advertisementArray forKey:key];
        [self.timeInfo setObject:@([[NSDate date] timeIntervalSince1970]) forKey:key];
        
        if (type == AdvertisementHomePage)
        {
            self.homepageAdvertiseArray = sortedArray;
        }
        else if (type == AdvertisementCarWash)
        {
            self.carwashAdvertiseArray = sortedArray;
            [[NSNotificationCenter defaultCenter] postNotificationName:CarwashAdvertiseNotification object:nil];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:CarwashAdvertiseNotification object:nil];
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
    
    NSTimeInterval timetag = [(NSNumber *)[self.timeInfo objectForKey:key] doubleValue];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    //超过时间间隔,则更新该广告信息
    if (timetag+kUpdateAdTimeInterval < now) {
        signal = [signal concat:[self rac_getAdvertisement:type]];
    }
    return signal;
}

- (RACSignal *)rac_scrollTimerSignal
{
    return [RACSignal interval:kScrollAdTimeInterval onScheduler:[RACScheduler scheduler]];
}

#pragma mark - Utility
- (NSArray *)filterAndSortAdList:(NSArray *)ads
{
    NSArray * filterArray = [ads arrayByFilteringOperator:^BOOL(HKAdvertisement * ad) {
        
        return [NSDate isDateValidWithBegin:ad.validStart andEnd:ad.validEnd];
    }];
    
    NSArray * sortedArray = [filterArray sortedArrayUsingComparator:^NSComparisonResult(HKAdvertisement * ad1, HKAdvertisement * ad2) {
        
        return ad1.weight > ad2.weight;
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
