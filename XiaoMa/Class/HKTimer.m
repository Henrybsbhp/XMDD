//
//  HKTimer.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTimer.h"

@implementation HKTimer

+ (RACSignal *)rac_timeCountDownWithOrigin:(NSTimeInterval)originTime andTimeTag:(NSTimeInterval)timeTag
{
    NSTimeInterval curTimeTag = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval leftTime = originTime - (curTimeTag - timeTag);
    return [[[[[RACSignal interval:1 onScheduler:[RACScheduler scheduler]]
               startWith:[NSDate date]] flattenMap:^RACStream *(id value) {
        
        NSTimeInterval curtimetag = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval leftTime = originTime - (curtimetag - timeTag);
        if (leftTime < 0) {
            return [RACSignal empty];
        }
        int leftDay = (int)leftTime / 3600 / 24; //取日
        int leftHour = (int)(leftTime - leftDay * 24 * 3600) / 3600; //取时
        int leftMinute = (int)(leftTime - leftDay * 24 *3600 - leftHour * 3600) / 60; //取分
        int leftSecond = (int)(leftTime - leftDay * 24 *3600 - leftHour * 3600 - leftMinute * 60); //取分
        NSString * dayStr = [NSString stringWithFormat:@"%d天", leftDay];
        NSString * hourStr = [NSString stringWithFormat:@"%d小时", leftHour];
        NSString * minuteStr = [NSString stringWithFormat:@"%d分", leftMinute];
        NSString * secondStr = [NSString stringWithFormat:@"%d秒", leftSecond];
        return [RACSignal return:[NSString stringWithFormat:@"%@%@%@%@", dayStr, hourStr, minuteStr, secondStr]];
    }] take:(int)leftTime] deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
