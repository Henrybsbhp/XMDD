//
//  NSDate(DateForText)
//
//
//  Created by jtang on 12-9-5 with appCode.
//  Copyright 2012 jtang.com.cn. All rights reserved.
//


#import "NSDate+DateForText.h"


@implementation NSDate (DateForText)

- (NSString *)textForDate
{
    NSString *dateText;
    if (self)
    {
        NSDate *currentDate = [NSDate date];
        int diff = (int)[currentDate timeIntervalSinceDate:self];
        if (diff < 60 * 60)
        {
            // 一小时内，显示在几分钟前
            NSInteger tempTime = diff / 60 + 1;
            if (tempTime < 2)
            {
                if (diff <= 30)
                {
                    dateText = [NSString stringWithFormat:@"30秒前"];
                }
                else
                {
                    dateText = [NSString stringWithFormat:@"%ld分钟前", (long)tempTime];
                }
            }
            else
            {
                dateText = [NSString stringWithFormat:@"%ld分钟前",(long)tempTime];
            }
        }
        else if (diff < 60 * 60 * 24)
        {
            // 24小时内，两种情况，同天和不同天
            // REV @jiangjunchen NSDateFormatter shoule be static
            NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
            [dayFormatter setDateFormat:@"dd"];

            NSString *currentDay = [dayFormatter stringFromDate:currentDate];
            NSString *lastTimeDay = [dayFormatter stringFromDate:self];
            if ([currentDay isEqualToString:lastTimeDay])
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm"];
                dateText = [formatter stringFromDate:self];
            }
            else
            {
                NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
                [monthDayFormatter setDateFormat:@"MM-dd"];
                dateText = [monthDayFormatter stringFromDate:self];
            }
        }
        else
        {
            // 超过一天，只显示日期
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM-dd"];
            dateText = [formatter stringFromDate:self];
        }
    }
    else
    {
        dateText = @"";
    }

    return dateText;
}

- (NSString *)dateFormatForYYMMdd
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}
- (NSString *)dateFormatForYYMMdd2
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

/// 时间格式化(yyyy-MM-dd)
- (NSString *)dateFormatForD10
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}


- (NSString *)dateFormatForYYYYMMddHHmm
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

- (NSString *)dateFormatForYYYYMMddHHmm2
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

- (NSString *)dateFormatForYYYYMMddHHmmss
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

- (NSString *)dateFormatForYYMM
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

- (NSString *)dateFormatForText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

- (NSString *)dateFormatForRefrenceText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

- (NSString *)dateFormatForDT15;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

- (NSString *)dateFormatForDT8;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dateToString = [dateFormatter stringFromDate:self];
    return dateToString;
}

+ (NSString *)dateFormatForYYYYMMddHHmmWithD15:(NSString *)text
{
    NSDate * date = [NSDate dateWithText:text];
    NSString * longText = [date dateFormatForYYYYMMddHHmm];
    return longText;
}

+ (NSDate *)dateWithD8Text:(NSString *)text
{
    if (text.length == 0) {
        return nil;
    }
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    return [format dateFromString:text];
}

+ (NSDate *)dateWithD10Text:(NSString *)text
{
    if (text.length == 0) {
        return nil;
    }
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    return [format dateFromString:text];
}

+ (NSDate *)dateWithUTS:(NSNumber*)uts
{
    if (!uts || uts.longLongValue == 0) {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)(uts.longLongValue/1000.0)];
}

+ (NSDate *)dateWithD14Text:(NSString *)text
{
    if (text.length == 0) {
        return nil;
    }
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMddHHmmss"];
    return [format dateFromString:text];
}

+ (NSDate *)dateWithText:(NSString *)text
{
    if (text.length == 0) {
        return nil;
    }

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd'T'HHmmss"];
    return [format dateFromString:text];
}

+ (NSString *)dateFormatStringForRefrenceTimeInteval:(NSTimeInterval)refrenceTime
{
    NSInteger ti = refrenceTime;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (((ti / 60) % 60) < 0) ? 0 :((ti / 60) % 60);
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"mm:ss"];
//    NSString *dateToString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:refrenceTime]];
//    return dateToString;
}

+ (BOOL)isDateValidWithBegin:(NSDate *)beginDate andEnd:(NSDate *)endDate
{
    NSDate * now = [NSDate date];
    if (now == [now earlierDate:beginDate])
    {
        return NO;
    }
    if (now == [now laterDate:endDate])
    {
        return NO;
    }
    return YES;
}
@end

@implementation NSString (DateForText)

- (NSString *)dataFormatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    NSString *dateToString = [dateFormatter stringFromDate:[NSDate dateWithText:self]];
    return dateToString;
}

@end
