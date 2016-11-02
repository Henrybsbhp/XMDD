//
//  RCTLoginManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTLoginManager.h"
#import "HKLoadingModel.h"
#import "LoginViewModel.h"

@implementation RCTLoginManager

RCT_EXPORT_MODULE()

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self subscribeSignals];
    }
    return self;
}

- (void)subscribeSignals {
    [[[RACObserve(gAppMgr, myUser) distinctUntilChanged] skip:1] subscribeNext:^(id x) {
        if (self.bridge) {
            [self sendEventWithName:@"login" body:@(x ? YES : NO)];
        }
    }];
}

RCT_EXPORT_METHOD(logout) {
    [HKLoginModel logout];
}

RCT_EXPORT_METHOD(loginIfNeeded:(RCTResponseSenderBlock)callback) {
    BOOL logined = [LoginViewModel loginIfNeededForTargetViewController:gAppMgr.navModel.curNavCtrl.topViewController];
    callback(@[@(logined)]);
}

RCT_EXPORT_METHOD(isLogin:(RCTResponseSenderBlock)callback) {
    callback(@[gAppMgr.myUser ? @YES : @NO]);
}

#pragma mark - Override
- (NSArray<NSString *> *)supportedEvents {
    return @[@"login"];
}

@end
