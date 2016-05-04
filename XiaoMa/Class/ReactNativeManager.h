//
//  ReactNativeManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKRCTPackageConfig.h"
#import "GetReactNativePackageOp.h"

@interface ReactNativeManager : NSObject

@property (nonatomic, strong, readonly) HKRCTPackageConfig *defaultPackageConfig;
@property (nonatomic, strong, readonly) HKRCTPackageConfig *latestPackageConfig;

- (void)loadDefaultBundle;
+ (instancetype)sharedManager;
- (RACSignal *)rac_checkPackageVersion;
- (RACSignal *)rac_downloadPackageWithPackageOp:(GetReactNativePackageOp *)pkgop;

@end
