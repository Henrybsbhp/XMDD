//
//  UIImage+Utilities.h
//  ECP4iPhone
//
//  Created by jtang on 12-6-1.
//  Copyright (c) 2012年 jtang.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Color)

/// 绘制指定颜色的图片
+ (UIImage *)imageFromColor:(UIColor *)color;
@end

@interface UIImage (ScaleImage)

/// 普通缩放图片，此方法线程安全
- (UIImage *)scaleToSize:(CGSize)newSize;
/// 等比缩放图片
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
/// 普通缩放图片，使用UIGraphics，非线程安全
- (UIImage *)scaleToSizeUseUIGraphics:(CGSize)newSize;
/// 等比压缩图片（按像素）
- (UIImage *)compressImageWithPixelSize:(CGSize)pixelSize;
/// 等比压缩图片（按point）
- (UIImage *)compressImageWithPointSize:(CGSize)pointSize;
/// 图片裁减（按point缩放）
- (UIImage *)generatePhotoThumbnailWithSize:(CGSize)thumbnailSize;
@end

@interface UIImage (Resize)
/// 剪裁图片到指定的尺寸
- (UIImage *)croppedImage:(CGRect)bounds;
/// 修正旋转方向
- (UIImage *)fixRotation;
@end

@interface UIImage (RoundedCorner)
/// 产生圆角的图片
- (UIImage *)makeImageRounded;
@end
