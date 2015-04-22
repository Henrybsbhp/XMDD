//
//  DeviceInfo.m
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo

- (instancetype)init
{
    self = [super init];
    
    _screenSize = [[UIScreen mainScreen] bounds].size;
    
    _screenScale = [[UIScreen mainScreen] scale];
    
    _osVersion = [[UIDevice currentDevice] systemVersion];
    
    return self;
}
@end
