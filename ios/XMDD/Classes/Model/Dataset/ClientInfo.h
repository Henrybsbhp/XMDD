//
//  ClientInfo.h
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientInfo : NSObject

@property (nonatomic, strong, readonly) NSString *clientVersion;

@property (nonatomic, strong) NSString *lastClientVersion;

/// 强制更新的版本
@property (nonatomic, copy)NSString * forceUpdateVersion;
/// 强制更新的链接
@property (nonatomic, copy)NSString * forceUpdateUrl;
/// 强制更新的内容
@property (nonatomic, copy)NSString * forceUpdateContent;

@end
