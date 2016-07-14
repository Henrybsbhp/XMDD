//
//  DeviceInfo.h
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ScreenWidth      [UIScreen mainScreen].bounds.size.width
#define ScreenHeight     [UIScreen mainScreen].bounds.size.height

@interface DeviceInfo : NSObject

///屏幕大小
@property (nonatomic, assign, readonly) CGSize screenSize;
@property (nonatomic, assign, readonly) CGFloat screenScale;

@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *appLongVersion;
@property (nonatomic, copy, readonly) NSString *osVersion;
///设备型号
@property (nonatomic, copy, readonly) NSString *deviceModel;
///设备唯一标识
@property (nonatomic, strong, readonly) NSString *deviceID;

///检测关键字是否第一次在当前版本出现过(没有出现过则更新)
- (BOOL)firstAppearAtThisVersionForKey:(NSString *)key;
///检测关键字是否第一次在当前版本出现过
- (BOOL)checkIfAppearedAtThisVersionForKey:(NSString *)key;
///检测关键字是否第一次在某版本之后（包含该版本）出现过(没有出现过则更新)
- (BOOL)firstAppearAfterVersion:(NSString *)version forKey:(NSString *)key;
///检测关键字是否第一次在某版本之后（包含该版本）出现过
- (BOOL)checkIfAppearedAfterVersion:(NSString *)version forKey:(NSString *)key;

@end
