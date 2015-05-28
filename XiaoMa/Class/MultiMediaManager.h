//
//  MultiMediaManager.h
//  HappyTrain
//
//  Created by jt on 14-11-25.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMCache.h"

typedef enum : NSInteger
{
    ImageURLTypeOrigin = 0,     //原图
    ImageURLTypeThumbnail,      //缩略图   128*128
    ImageURLTypeMedium,         //中图     1024*1024
}ImageURLType;

@interface MultiMediaManager : NSObject

///图像缓存（可手动清除）
@property (nonatomic, strong, readonly) TMCache *picCache;

- (instancetype)initWithPicCache:(TMCache *)cache;

/// 图片下载, 先去缓存中查询，如果没有查到就去网络上下载。注意：catch中查找可能返回nil，网络下载也可能返回nil。
- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withDefaultPic:(NSString *)picName;

- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withDefaultPic:(NSString *)defPicName errorPic:(NSString *)errPicName;

- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withType:(ImageURLType)type
                         defaultPic:(NSString *)defPicName errorPic:(NSString *)errPicName;

///拍照、从相册获取照片
- (RACSignal *)rac_pickPhotoInTargetVC:(UIViewController *)targetVC inView:(UIView *)view;


@end
