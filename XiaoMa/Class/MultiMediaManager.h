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

#define kImagePickerDelayDismiss @"$DelayDismiss"
#define kImagePickerCompress  @"$Compress"

@interface MultiMediaManager : NSObject

///图像缓存（可手动清除）
@property (nonatomic, strong, readonly) TMCache *picCache;

- (instancetype)initWithPicCache:(TMCache *)cache;

/// 图片下载, 先去缓存中查询，如果没有查到就去网络上下载。
- (RACSignal *)rac_getPictureForUrl:(NSString *)url defaultPic:(NSString *)defName;
/// 图片下载, 先去缓存中查询，如果没有查到就去网络上下载。
- (RACSignal *)rac_getPictureForUrl:(NSString *)url withType:(ImageURLType)type defaultPic:(NSString *)defName;
/// 图片下载, 先去缓存中查询，如果没有查到就去网络上下载。
- (RACSignal *)rac_getPictureForUrl:(NSString *)url withType:(ImageURLType)type
                         defaultPic:(NSString *)defPicName errorPic:(NSString *)errPicName;
///拍照、从相册获取照片
- (RACSignal *)rac_pickPhotoInTargetVC:(UIViewController *)targetVC inView:(UIView *)view;
- (RACSignal *)rac_pickPhotoInTargetVC:(UIViewController *)targetVC
                                inView:(UIView *)view initBlock:(void(^)(UIImagePickerController *picker))block;
- (RACSignal *)rac_pickAndCropPhotoInTargetVC:(UIViewController *)targetVC inView:(UIView *)view;

@end
