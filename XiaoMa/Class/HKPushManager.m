//
//  HKPushManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKPushManager.h"
#import "BindDeviceToken2Op.h"

@implementation HKPushManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bindOp = [BindDeviceTokenOp operation];
        _bindOp.req_osversion = [NSString stringWithFormat:@"iOS %@", gAppMgr.deviceInfo.osVersion];
        _bindOp.req_appversion = gAppMgr.deviceInfo.appVersion;
        _bindOp.req_deviceID = gAppMgr.deviceInfo.deviceID;
        [self setupNotifyQueue];
    }
    return self;
}

- (void)setupNotifyQueue
{
    [self.notifyQueue setConsumeBlock:^RACSignal *(NSDictionary *info, id<NSCopying>key) {
        
        [gAppMgr.navModel pushToViewControllerByUrl:info[@"url"]];
        return [RACSignal empty];
    }];
}

#pragma mark - Override
- (void)registerDeviceToken:(NSData *)deviceToken
{
    self.bindOp.req_deviceToken = [deviceToken hexadecimalString];
}

- (void)handleNofitication:(NSDictionary *)info forApplication:(UIApplication *)application
{
    [super handleNofitication:info forApplication:application];
    //应用外推送
    if (application.applicationState == UIApplicationStateActive) {
        [self.notifyQueue removeAllObjects];
        [self.notifyQueue addObject:info forKey:nil];
    }
}

#pragma mark - Public
- (void)autoBindDeviceTokenInBackground
{
    RACSignal *sig1 = [[RACObserve(self.bindOp, req_deviceToken) distinctUntilChanged] filter:^BOOL(NSString *token) {
        return token.length > 0;
    }];
    RACSignal *sig2 = [[RACObserve(gAppMgr, myUser) distinctUntilChanged] filter:^BOOL(id value) {
        return (BOOL)value;
    }];
    @weakify(self);
    [[[[sig1 merge:sig2] skip:1] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self.bindOp rac_postRequest];
    }] subscribeNext:^(BindDeviceTokenOp *rspOp) {
        DebugLog(@"Bind device token success!(deviceToken:%@ user:%@ deviceID:%@)",
                 rspOp.req_deviceToken, gAppMgr.myUser.userID, gAppMgr.deviceInfo.deviceID);
    }];
    
    [[sig1 flattenMap:^RACStream *(NSString *token) {
        @strongify(self);
        BindDeviceToken2Op *op = [BindDeviceToken2Op operation];
        op.req_osversion = self.bindOp.req_osversion;
        op.req_appversion = self.bindOp.req_appversion;
        op.req_deviceID = self.bindOp.req_deviceID;
        op.req_deviceToken = token;
        return [op rac_postRequest];
    }] subscribeNext:^(BindDeviceToken2Op *rspOp) {
        DebugLog(@"Bind global device token success!(deviceToken:%@ deviceID:%@)",
                 rspOp.req_deviceToken, rspOp.req_deviceID);
    }];
}


@end
