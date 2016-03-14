//
//  HKTimer.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKTimer : NSObject

+ (RACSignal *)rac_timeCountDownWithOrigin:(NSTimeInterval)originTime andTimeTag:(NSTimeInterval)timeTag;

@end
