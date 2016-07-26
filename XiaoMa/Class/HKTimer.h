//
//  HKTimer.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKTimer : NSObject

//*重要*入参originTime为接口获取的剩余时间；入参timeTag应为通过接口获取到数据时的时间戳

+ (RACSignal *)rac_timeCountDownWithOrigin:(NSTimeInterval)originTime andTimeTag:(NSTimeInterval)timeTag;
+ (RACSignal *)rac_startWithOrigin:(NSTimeInterval)originTime andTimeTag:(NSTimeInterval)timeTag;
+ (NSString *)ddhhmmssFormatWithTimeInterval:(NSTimeInterval)leftTime;
+ (NSString *)ddhhmmFormatWithTimeInterval:(NSTimeInterval)leftTime;
+ (NSString *)hhmmssFormatWithTimeInterval:(NSTimeInterval)leftTime;

@end
