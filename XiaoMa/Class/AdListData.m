//
//  AdListData.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "AdListData.h"

@implementation AdListData

+ (BOOL)checkAdAlreadyAppeard:(HKAdvertisement *)adDic
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"ad_id_%@", adDic.adId];
    if ([def objectForKey:key]) {
        return YES;
    }
    return NO;
}

+ (void)recordAdArray:(NSArray *)adArr
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < adArr.count; i ++) {
        HKAdvertisement *adDic = adArr[i];
        NSString * key = [NSString stringWithFormat:@"ad_id_%@", adDic.adId];
        if (![def objectForKey:key]) {
            [def setObject:adDic.adId forKey:key];
        }
    }
}

@end
