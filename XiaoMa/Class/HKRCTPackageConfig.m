//
//  HKReactNativeConfig.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/29.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKRCTPackageConfig.h"

@implementation HKRCTPackageConfig

+ (instancetype)configWithUrl:(NSURL *)url
{
    HKRCTPackageConfig *config = [[self alloc] init];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithURL:url options:NSJSONWritingPrettyPrinted error:&error];
    if (!dict && error) {
        DebugErrorLog([error description]);
    }
    config->_bundleVersion = dict[@"version"];
    config->_minAppVersion = dict[@"min-app-version"];
    config->_descList = dict[@"desc"];
    return config;
}

@end