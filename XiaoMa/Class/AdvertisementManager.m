//
//  AdvertisementManager.m
//  XiaoMa
//
//  Created by jt on 15-5-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AdvertisementManager.h"
#import "GetSystemPromotionOp.h"

@interface AdvertisementManager()

@property (nonatomic, strong, readonly) TMCache *adCache;

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
    }
    return self;
}


- (RACSignal *)rac_getAdvertisement:(AdvertisementType)type
{
    RACSignal * signal;
    GetSystemPromotionOp * op = [GetSystemPromotionOp operation];
    op.type = type;
    signal = [[op rac_postRequest] flattenMap:^RACStream *(GetSystemPromotionOp * op) {
        
        NSArray * filterArray = [op.rsp_advertisementArray arrayByFilteringOperator:^BOOL(HKAdvertisement * ad) {
            
            return [NSDate isDateValidWithBegin:ad.validStart andEnd:ad.validEnd];
        }];
        
        NSArray * sortedArray = [filterArray sortedArrayUsingComparator:^NSComparisonResult(HKAdvertisement * ad1, HKAdvertisement * ad2) {
            
            return ad1.weight > ad2.weight;
        }];

        if (type == AdvertisementHomePage)
        {
            self.homepageAdvertiseArray = sortedArray;
            [self saveInfo:op.rsp_advertisementArray forKey:HomepageAdvertise];
        }
        else if (type == AdvertisementCarWash)
        {
            self.carwashAdvertiseArray = sortedArray;
            [self saveInfo:op.rsp_advertisementArray forKey:CarwashAdvertise];
            [[NSNotificationCenter defaultCenter] postNotificationName:CarwashAdvertiseNotification object:nil];
        }
        
        
        return [RACSignal return:op.rsp_advertisementArray];
    }];
    return signal;
}

#pragma mark - 获取上次
- (NSArray *)loadLastAdvertiseInfo:(AdvertisementType)type
{
    NSString * key;
    if (type == AdvertisementHomePage)
    {
        key = HomepageAdvertise;
    }
    else if (type == AdvertisementCarWash)
    {
        key = CarwashAdvertise;
    }
    NSArray * array = [self.adCache objectForKey:key];
    if (type == AdvertisementHomePage)
    {
        self.homepageAdvertiseArray = array;
    }
    else if (type == AdvertisementCarWash)
    {
        self.carwashAdvertiseArray = array;
        [[NSNotificationCenter defaultCenter] postNotificationName:CarwashAdvertiseNotification object:nil];
    }
    return array;
}



#pragma mark - 数据存取
- (void)saveInfo:(id <NSCoding>)value forKey:(NSString *)key
{
    CKAsyncHighQueue(^{
        [self.adCache setObject:value forKey:key];
    });
}

@end
