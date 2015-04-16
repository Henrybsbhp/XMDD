//
//  MultiMediaManager.h
//  HappyTrain
//
//  Created by jt on 14-11-25.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMCache.h"

@interface MultiMediaManager : NSObject

///图像缓存（可手动清除）
@property (nonatomic, strong, readonly) TMCache *picCache;

+ (instancetype)sharedManager;

/// 图片下载, 先去缓存中查询，如果没有查到就去网络上下载。注意：catch中查找可能返回nil，网络下载也可能返回nil。
- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withDefaultPic:(NSString *)picName;

///图片验证码
- (RACSignal *)rac_gainCaptcha:(NSString *)account;

- (RACSignal *)rac_gainCaptchaImage:(NSString *)url;

/// 图片验证码和Url
- (RACSignal *)rac_gainCaptchaAndUrl:(NSString *)account;

/// 区域编码文件下载
- (RACSignal *)rac_getAreaFile:(NSString *)url;

@end
