//
//  HKLaunchManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKLaunchManager.h"
#import "getLaunchInfoOp.h"
#import "NSDate+DateForText.h"

///每12小时更新内容
#define kUpdateInfoTimeInterval       60*60*12


@implementation HKLaunchManager

- (void)checkLaunchInfoUpdating
{
    [[self rac_fetchLaunchInfoIfNeeded] subscribeNext:^(NSArray *adlist) {
        for (HKLaunchInfo *ad in adlist) {
            NSString *adurl = [ad croppedPicUrl];
            BOOL cached = [gMediaMgr cachedImageExistsForUrl:adurl];
            if (!cached) {
                [[gMediaMgr rac_getImageByUrl:adurl withType:ImageURLTypeOrigin defaultPic:nil errorPic:nil] subscribeNext:^(id x) {
                    
                }];
            }
        }
    }];
}

- (HKLaunchInfo *)fetchLatestLaunchInfo
{
    NSDictionary *dict = [GetLaunchInfoOp fetchSavedLaunchInfosDict];
    NSArray *infos = [GetLaunchInfoOp parseLuanchInfosWithDict:dict];
    return [[self filterAndSortInfoList:infos] safetyObjectAtIndex:0];
}

- (RACSignal *)rac_fetchLaunchInfoIfNeeded
{
    NSDictionary *dict = [GetLaunchInfoOp fetchSavedLaunchInfosDict];
    RACSignal *signal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {
        NSArray *infos = [GetLaunchInfoOp parseLuanchInfosWithDict:dict];
        [subscriber sendNext:[self filterAndSortInfoList:infos]];
        [subscriber sendCompleted];
    }];
    
    NSTimeInterval timetag = self.timetag;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    //超过时间间隔,则更新信息
    if (timetag+kUpdateInfoTimeInterval < now) {
        signal = [signal concat:[self rac_getLaunchInfo]];
    }
    else {
        HKAddressComponent *ac = [GetLaunchInfoOp parseAddressWithDict:dict];
        if (![HKAddressComponent isEqualAddrComponent:ac otherAddrComponent:gMapHelper.addrComponent]) {
            signal = [signal concat:[self rac_getLaunchInfo]];
        }
        
    }
    return signal;
}

- (RACSignal *)rac_getLaunchInfo
{
    @weakify(self);
    return [[[[gMapHelper rac_getInvertGeoInfo] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal return:nil];
    }] flattenMap:^RACStream *(AMapReGeocode *reGeocode) {
        
        GetLaunchInfoOp *op = [GetLaunchInfoOp operation];
        op.req_province = reGeocode.addressComponent.province;
        op.req_city = reGeocode.addressComponent.city;
        op.req_district = reGeocode.addressComponent.district;
        return [op rac_postRequest];
    }]  map:^id(GetLaunchInfoOp *rspop) {
        
        @strongify(self);
        self.timetag = [[NSDate date] timeIntervalSince1970];
        return rspop.rsp_infoList;
    }];
}

- (NSArray *)filterAndSortInfoList:(NSArray *)ads
{
    NSArray * filterArray = [ads arrayByFilteringOperator:^BOOL(HKLaunchInfo * ad) {
        
        return [NSDate isDateValidWithBegin:ad.starttime andEnd:ad.endtime];
    }];
    
    NSArray * sortedArray = [filterArray sortedArrayUsingComparator:^NSComparisonResult(HKLaunchInfo * ad1, HKLaunchInfo * ad2) {
        
        return ad1.weight > ad2.weight ? NSOrderedAscending : (ad1.weight == ad2.weight ? NSOrderedSame : NSOrderedDescending);
    }];
    return sortedArray;
}
@end
