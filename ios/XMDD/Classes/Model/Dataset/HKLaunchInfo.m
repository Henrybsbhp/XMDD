//
//  HKLaunchInfo.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKLaunchInfo.h"
#import "NSDate+DateForText.h"

@implementation HKLaunchInfo

+ (instancetype)launchInfoWithJSONResponse:(NSDictionary *)rsp
{
    HKLaunchInfo *info = [[HKLaunchInfo alloc] init];
    info.staytime = [rsp[@"staytime"] integerValue] / 1000.0;
    info.starttime = [NSDate dateWithUTS:rsp[@"starttime"]];
    info.endtime = [NSDate dateWithUTS:rsp[@"endtime"]];
    info.picurl = rsp[@"pic"];
    info.fullscreen = [rsp[@"fullscreen"] integerValue] == 1;
    info.weight = [rsp[@"weight"] integerValue];
    info.url = [rsp stringParamForName:@"url"];
    return info;
}

- (NSString *)croppedPicUrl
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    size.width = size.width * scale;
    size.height = (size.height - (self.fullscreen ? 0 : kLaunchBottomViewHeight)) * scale;
    return [gMediaMgr urlWith:self.picurl croppedSize:size];
}

@end
