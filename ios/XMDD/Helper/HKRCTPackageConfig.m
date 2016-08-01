//
//  HKReactNativeConfig.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/29.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKRCTPackageConfig.h"

@implementation HKRCTPackageConfig

+ (instancetype)configWithPath:(NSString *)path
{
    HKRCTPackageConfig *config = [[self alloc] init];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!dict && error) {
        DebugErrorLog([error description]);
        return nil;
    }
    config->_bundleVersion = dict[@"version"];
    config->_minAppVersion = dict[@"min-app-version"];
    config->_timetag = dict[@"timetag"];
    config->_projectName = dict[@"project-name"];
    config->_buildType = dict[@"build-type"];
    return config;
}

@end