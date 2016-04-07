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
        if (comps1.day == comps2.day) {
            [dateFormatter setDateFormat:@"今天 HH:mm"];
        }
        else {
            [dateFormatter setDateFormat:@"昨天 HH:mm"];
        }
        dateText = [dateFormatter stringFromDate:self];
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
