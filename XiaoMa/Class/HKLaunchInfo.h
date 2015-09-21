//
//  HKLaunchInfo.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKLaunchInfo : NSObject

@property (nonatomic, assign) NSTimeInterval staytime;
@property (nonatomic, strong) NSDate *starttime;
@property (nonatomic, strong) NSDate *endtime;
@property (nonatomic, strong) NSString *picurl;
@property (nonatomic, assign) BOOL fullscreen;
@property (nonatomic, assign) NSInteger weight;

+ (instancetype)launchInfoWithJSONResponse:(NSDictionary *)rsp;
- (NSString *)croppedPicUrl;

@end
