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
- (NSString *)dateFormatForLongText;
/// 时间格式化(yyyy年MM月dd日)
- (NSString *)dateFormatForShortText;
/// D15时间格式化(yyyy年MM月dd日)
+ (NSString *)dateFormatForLongTextWithD15:(NSString *)text;
///参照时间(mm:ss)
- (NSString *)dateFormatForRefrenceText;
- (NSString *)dateFormatForDT15;
- (NSString *)dateFormatForDT8;
+ (NSDate *)dateWithD8Text:(NSString *)text;
+ (NSDate *)dateWithText:(NSString *)text;

///参照时间(mm:ss)
+ (NSString *)dateFormatStringForRefrenceTimeInteval:(NSTimeInterval)refrenceTime;
@end

@interface NSString (DateForText)
/// 时间格式(MM月dd日 HH:mm)
- (NSString *)dataFormatString;

@end
