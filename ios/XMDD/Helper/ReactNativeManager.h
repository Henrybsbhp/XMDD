//
//  ReactNativeManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyUserStore.h"
#import "HKRCTPackageConfig.h"
#import "GetReactNativePackageOp.h"

@interface ReactNativeManager : MyUserStore

@property (nonatomic, strong, readonly) RACSignal *loadingSignal;
@property (nonatomic, strong, readonly) HKRCTPackageConfig *defaultPackageConfig;
@property (nonatomic, strong, readonly) HKRCTPackageConfig *latestPackageConfig;


- (void)loadDefaultBundle;
+ (instancetype)sharedManager;

//// 检测是否支持开启react native
- (BOOL)checkReactNativeEnabledIfNeeded;

//// Update
- (RACSignal *)rac_checkPackageVersion;
- (RACSignal *)rac_downloadPackageWithPackageOp:(GetReactNativePackageOp *)pkgop;
- (RACSignal *)rac_checkAndUpdatePackage;
- (RACSignal *)rac_checkAndUpdatePackageIfNeeded;

//// Util
- (NSURL *)latestJSBundleUrl;

@end
