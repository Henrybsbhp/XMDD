//
//  HKReactNativeConfig.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/29.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKRCTPackageConfig : NSObject

@property (nonatomic, strong, readonly) NSString *bundleVersion;
@property (nonatomic, strong, readonly) NSString *minAppVersion;
@property (nonatomic, strong, readonly) NSArray *descList;

+ (instancetype)configWithUrl:(NSURL *)url;

@end
