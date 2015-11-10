//
//  NSDate(DateForText)
//
//
//  Created by jtang on 12-9-5 with appCode.
//  Copyright 2012 jtang.com.cn. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSDate (DateForText)

/// 当天显示时间，昨天显示昨天，再往前就显示日期加时间
- (NSString *)textForDate;
/// 时间格式化(MM月dd日 HH:mm)
- (NSString *)dateFormatForText;
/// 时间格式化(yyyy年MM月dd日 HH:mm)
- (NSString *)dateFormatForYYYYMMddHHmm;
/// 时间格式化(yyyy.MM.dd HH:mm)
- (NSString *)dateFormatForYYYYMMddHHmm2;
/// 时间格式化(yyyy年MM月dd日)
- (NSString *)dateFormatForYYMMdd;
/// 时间格式化(yyyy.MM.dd)
- (NSString *)dateFormatForYYMMdd2;
/// 时间格式化(yyyy年MM月)
- (NSString *)dateFormatForYYMM;
/// D15时间格式化(yyyy年MM月dd日)
+ (NSString *)dateFormatForYYYYMMddHHmmWithD15:(NSString *)text;
///参照时间(mm:ss)
- (NSString *)dateFormatForRefrenceText;
+ (NSDate *)dateWithUTS:(NSNumber*)uts;
- (NSString *)dateFormatForDT15;
- (NSString *)dateFormatForDT8;
+ (NSDate *)dateWithD8Text:(NSString *)text;
+ (NSDate *)dateWithD14Text:(NSString *)text;
+ (NSDate *)dateWithText:(NSString *)text;

///参照时间(mm:ss)
+ (NSString *)dateFormatStringForRefrenceTimeInteval:(NSTimeInterval)refrenceTime;

+ (BOOL)isDateValidWithBegin:(NSDate * )beginDate andEnd:(NSDate *)endDate;
@end

@interface NSString (DateForText)
/// 时间格式(MM月dd日 HH:mm)
- (NSString *)dataFormatString;

@end
