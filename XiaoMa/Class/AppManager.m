//
//  AppManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

+ (AppManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static AppManager *g_appManager;
    dispatch_once(&onceToken, ^{
        g_appManager = [[AppManager alloc] init];
    });
    return g_appManager;
}

- (void)resetWithAccount:(NSString *)account
{
    if (!account)
    {
        self.myUser = nil;
        return;
    }
    JTUser *user = [JTUser new];
    //TODO:临时数据
    user.userID = @"123456";
    user.userName = @"陈大白";
    user.avatarUrl = @"tmp_a1";
    user.carwashTicketsCount = @2;
    user.abcCarwashTimesCount = @4;
    user.abcIntegral = @40000;
    user.numberPlate = @"浙A12345";
    self.myUser = user;
}

@end
