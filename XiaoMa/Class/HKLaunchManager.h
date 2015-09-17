//
//  HKLaunchManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKLaunchInfo.h"

@interface HKLaunchManager : NSObject
@property (nonatomic, assign) NSTimeInterval timetag;
- (void)checkLaunchInfoUpdating;
- (HKLaunchInfo *)fetchLatestLaunchInfo;

@end
