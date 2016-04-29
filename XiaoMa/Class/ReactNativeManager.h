//
//  ReactNativeManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKRCTPackageConfig.h"

@interface ReactNativeManager : NSObject

@property (nonatomic, strong, readonly) HKRCTPackageConfig *defaultConfig;

- (void)loadDefaultBundle;
+ (instancetype)sharedManager;

@end
