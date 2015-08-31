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
    ImageURLTypeThumbnail,      //缩略图     128*128
    ImageURLTypeMedium          //中图       1024*1024
}ImageURLType;

@interface MultiMediaManager : NSObject

- (UIImage *)imageFromMemoryCacheForUrl:(NSString *)strurl;
- (UIImage *)imageFromDiskCacheForUrl:(NSString *)strurl;
- (BOOL)cachedImageExistsForUrl:(NSString *)strurl;
- (BOOL)diskImageExistsForUrl:(NSString *)strurl;
- (NSString *)urlWith:(NSString *)url imageType:(ImageURLType)type;
- (RACSignal *)rac_getImageByUrl:(NSString *)strurl withType:(ImageURLType)type
                      defaultPic:(NSString *)defName errorPic:(NSString *)errName;
@end
