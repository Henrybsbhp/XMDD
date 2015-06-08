//
//  UIImage+Utility.h
//  JTReader
//
//  Created by jiangjunchen on 14-1-17.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)
/// 等比压缩图片（按像素）
- (UIImage *)compressImageWithPixelSize:(CGSize)pixelSize;
/// 等比压缩图片（按point）
- (UIImage *)compressImageWithPointSize:(CGSize)pointSize;
/// 图片裁减（按point缩放）
- (UIImage *)generatePhotoThumbnailWithSize:(CGSize)thumbnailSize;
///图片叠加
-(UIImage *)addImage:(UIImage *)image1 edgeInsets:(UIEdgeInsets)insets;
/// 方向调整
- (UIImage *)fixOrientation;

+ (UIImage *)imageWithStartColor:(UIColor *)color endColor:(UIColor *)color size:(CGSize)size;

@end
