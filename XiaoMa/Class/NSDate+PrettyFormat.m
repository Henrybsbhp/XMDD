//
//  NSDate+PrettyFormat.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/29.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "NSDate+PrettyFormat.h"

@implementation NSDate (PrettyFormat)

- (NSString *)prettyDateFormat
{
    NSDate *currentDate = [NSDate date];
    int diff = (int)[currentDate timeIntervalSinceDate:self];
    NSString *dateText = @"";
    if (diff < 60 * 60 * 24) {
        // 24小时内，两种情况，同天和不同天
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps1 = [calendar components:NSCalendarUnitDay fromDate:self];
        NSDateComponents *comps2 = [calendar components:NSCalendarUnitDay fromDate:currentDate];
        NSDateComponents *hourComps1 = [calendar components:NSCalendarUnitHour fromDate:self];
        
        NSDate * date;
        if (comps1.day == comps2.day) {
            if (hourComps1.hour >= 13)
            {
                date = [NSDate dateWithTimeInterval:12*60*60 sinceDate:self];
                [dateFormatter setDateFormat:@"今天 下午 HH:mm"];
            }
            else
            {
                date = self;
                [dateFormatter setDateFormat:@"今天 上午 HH:mm"];
            }
        }
        else {
            if (hourComps1.hour >= 13)
            {
                date = [NSDate dateWithTimeInterval:12*60*60 sinceDate:self];
                [dateFormatter setDateFormat:@"昨天 下午 HH:mm"];
            }
            else
            {
                date = self;
                [dateFormatter setDateFormat:@"昨天 上午 HH:mm"];
            }
        }
        dateText = [dateFormatter stringFromDate:date];
    }
    else {
        // 超过一天
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        dateText = [dateFormatter stringFromDate:self];
    }
    return dateText;
}

@end
