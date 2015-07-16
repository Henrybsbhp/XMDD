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

- (NSString *)urlWith:(NSString *)url imageType:(ImageURLType)type;
///从本地缓存获取image
- (RACSignal *)rac_getImageFromCacheWithUrl:(NSString *)url;
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
/**
 *  获取图片信号，第一次的信号返回NSString，用来标记一下。前端可用作风火轮提示
 *
 *  @param url     url
 *  @param type    图片类型
 *  @param defName 默认图片
 *  @param errName 错误图片
 *
 *  @return 图片及NSString信号
 */
- (RACSignal *)rac_getPictureForSpecialFirstTime:(NSString *)url withType:(ImageURLType)type
                                      defaultPic:(NSString *)defName errorPic:(NSString *)errName;

@end
