//
//  MultiMediaManager.m
//  HappyTrain
//
//  Created by jt on 14-11-25.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "MultiMediaManager.h"
#import "DownloadOp.h"
#import <CKKit.h>
#import <SDWebImageManager.h>

#define kPicCacheName    @"MultiMediaManager_PicCache"

@interface MultiMediaManager()
@end

@implementation MultiMediaManager

- (UIImage *)imageFromMemoryCacheForUrl:(NSString *)strurl
{
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    if (strurl) {
        return [mgr.imageCache imageFromMemoryCacheForKey:[mgr cacheKeyForURL:[NSURL URLWithString:strurl]]];
    }
    return nil;
}

- (UIImage *)imageFromDiskCacheForUrl:(NSString *)strurl
{
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    if (strurl) {
        return [mgr.imageCache imageFromDiskCacheForKey:[mgr cacheKeyForURL:[NSURL URLWithString:strurl]]];
    }
    return nil;
}


- (BOOL)cachedImageExistsForUrl:(NSString *)strurl
{
    if (!strurl) {
        return NO;
    }
    NSURL *url = [NSURL URLWithString:strurl];
    return [[SDWebImageManager sharedManager] cachedImageExistsForURL:url];
}

- (BOOL)diskImageExistsForUrl:(NSString *)strurl
{
    if (!strurl) {
        return NO;
    }
    NSURL *url = [NSURL URLWithString:strurl];
    return [[SDWebImageManager sharedManager] diskImageExistsForURL:url];
}

- (void)saveImageToCache:(UIImage *)image forUrl:(NSString *)strurl
{
    if (!strurl) {
        return;
    }
    NSURL *url = [NSURL URLWithString:strurl];
    [[SDWebImageManager sharedManager] saveImageToCache:image forURL:url];
}

- (RACSignal *)rac_getImageByUrl:(NSString *)strurl withType:(ImageURLType)type
                      defaultPic:(NSString *)defName errorPic:(NSString *)errName
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *realStrUrl = [gMediaMgr urlWith:strurl imageType:type];
        NSURL *url = strurl ? [NSURL URLWithString:realStrUrl] : nil;
        SDWebImageManager *mgr = [SDWebImageManager sharedManager];
        if (defName && url && ![mgr cachedImageExistsForURL:url]) {
            [subscriber sendNext:[UIImage imageNamed:defName]];
        }
        [mgr downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                [subscriber sendNext:image];
            }
            else if (error) {
                if (errName.length > 0) {
                    [subscriber sendNext:[UIImage imageNamed:errName]];
                }
                else {
                    [subscriber sendError:error];
                }
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (NSString *)urlWith:(NSString *)url croppedSize:(CGSize)size
{
    NSString *suffix = [NSString stringWithFormat:@"?imageView2/1/w/%d/h/%d", (int)size.width, (int)size.height];
    return [url append:suffix];
}

- (NSString *)urlWith:(NSString *)url imageType:(ImageURLType)type
{
    if (type == ImageURLTypeThumbnail) {
        url = [url append:@"?imageView2/1/w/128/h/128"];
    }
    else if (type == ImageURLTypeMedium) {
        url = [url append:@"?imageView2/0/w/1024/h/1024"];
    }
    return url;
}


@end
