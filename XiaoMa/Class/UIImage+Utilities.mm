//
//  UIImage+Utilities.m
//  ECP4iPhone
//
//  Created by jtang on 12-6-1.
//  clf made it
//  Copyright (c) 2012年 jtang.com.cn. All rights reserved.
//

#import "UIImage+Utilities.h"
//#import "DebugLog.h"

@implementation UIImage (Color)

+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

@implementation UIImage (ScaleImage)

/********************************************************************
 *
 *  Function:缩放图片，线程安全
 *
 *  Parameter:
 *      newSize:缩放后的图片大小
 *
 *  Return:
 *      UIImage:返回缩放后的图片指针
 *
 *  Noted by 曦 曦 on 12-3-2.
 *
 ********************************************************************/
- (UIImage *)scaleToSizeUseUIGraphics:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);

    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaleToSize:(CGSize)newSize
{
    UIImage *sourceImage = self;
    CGFloat targetWidth = newSize.width;
    CGFloat targetHeight = newSize.height;


    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);

    if (bitmapInfo == kCGImageAlphaNone)
    {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }

    CGContextRef bitmap;


    if (sourceImage.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationDown)
    {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight,
                                       CGImageGetBitsPerComponent(imageRef),
                                       CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);

    }
    else
    {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth,
                                       CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef),
                                       colorSpaceInfo, bitmapInfo);

    }

    if (sourceImage.imageOrientation == UIImageOrientationLeft)
    {
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);

    }
    else if (sourceImage.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);

    }
    else if (sourceImage.imageOrientation == UIImageOrientationUp)
    {
        // NOTHING
    }
    else if (sourceImage.imageOrientation == UIImageOrientationDown)
    {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }

    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];

    CGContextRelease(bitmap);
    CGImageRelease(ref);

    return newImage;
}

/// 等比压缩图片（按像素）
- (UIImage *)compressImageWithPixelSize:(CGSize)pixelSize
{
    CGImageRef imageRef = self.CGImage;
    CGFloat oldHeight = CGImageGetHeight(imageRef);
    CGFloat oldWidth = CGImageGetWidth(imageRef);
    //长和宽都小于压缩大小，不压缩
    if (oldHeight < pixelSize.height && oldWidth < pixelSize.width)
    {
        return self;
    }
    CGFloat thumbnailScale = pixelSize.width/pixelSize.height;
    CGFloat scale = oldWidth/oldHeight;
    CGSize newSize = CGSizeMake(oldWidth, oldHeight);
  //  CGFloat newX = 0;
  //  CGFloat newY = 0;
    if (scale > thumbnailScale)
    {
        newSize.width = pixelSize.width;
        newSize.height = newSize.width/scale;
  //      newY = (pixelSize.height - newSize.height)*0.5;
    }
    else
    {
        newSize.height = pixelSize.height;
        newSize.width = newSize.height*scale;
  //      newX = (pixelSize.width - newSize.width)*0.5;
    }
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();

    CGContextRef bitmap = CGBitmapContextCreate(NULL, newSize.width, newSize.height,
                                                8, 0, colorSpaceInfo, kCGImageAlphaNoneSkipLast);
    CGColorSpaceRelease(colorSpaceInfo);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, newSize.width, newSize.height), imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    CGContextRelease(bitmap);
    return newImage;
}

// 等比压缩图片（按point）
- (UIImage *)compressImageWithPointSize:(CGSize)pointSize
{
    CGSize piexlSize = pointSize;
    CGFloat scale = [UIScreen mainScreen].scale;
    piexlSize.width  *= scale;
    piexlSize.height *= scale;
    return [self compressImageWithPixelSize:piexlSize];
}

// 图片裁减（按point缩放）
- (UIImage *)generatePhotoThumbnailWithSize:(CGSize)thumbnailSize
{
    CGSize size = self.size;
    CGFloat scale = self.size.width/self.size.height;
    CGFloat thumbnailX = 0.0;
    CGFloat thumbnailY = 0.0;
    CGFloat thumbnailScale = thumbnailSize.width/thumbnailSize.height;
    if (scale > thumbnailScale)
    {
        size.width = self.size.height*thumbnailScale;
        thumbnailX = (self.size.width - size.width)/2;
    }
    else
    {
        size.height = self.size.width/thumbnailScale;
        thumbnailY = (self.size.height - size.height)/2;

    }
    CGRect temp_rect = CGRectMake(thumbnailX, thumbnailY, size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, temp_rect);
    CGRect thumbnailRect = CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height);
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0.0);
    [[UIImage imageWithCGImage:imageRef] drawInRect:thumbnailRect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
//    DebugLog(@"%@",NSStringFromCGSize(thumbnail.size));
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);

    return thumbnail;
}

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }

        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    CGImageRef imageRef = [sourceImage CGImage];
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();

    CGContextRef bitmap;

    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown)
    {
       bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, 8, 0, colorSpaceInfo, kCGImageAlphaNoneSkipLast);
    }
    else
    {
       bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, 8, 0, colorSpaceInfo, kCGImageAlphaNoneSkipLast);

    }

    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];

    CGContextRelease(bitmap);
    CGImageRelease(ref);
    CGColorSpaceRelease(colorSpaceInfo);

    if (newImage == nil)
    {
        //JTDDLogWarm(@"could not scale image");
    }

    return newImage;
}
@end

@implementation UIImage (Resize)

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (UIImage *)fixRotation
{
    // REV 代码长度超过100
    int kMaxResolution = self.size.width;
    if (self.size.height > kMaxResolution)
    {
        kMaxResolution = self.size.height;
    }

    CGImageRef imgRef = self.CGImage;

    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);

    CGAffineTransform transform;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution)
    {
        CGFloat ratio = width / height;
        if (ratio > 1)
        {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }

    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch (orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;

        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;

        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;

        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;

        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;

        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;

        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;

        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }

    UIGraphicsBeginImageContext(bounds.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }

    CGContextConcatCTM(context, transform);

    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imageCopy;
}

@end


@implementation UIImage (RoundedCorner)

- (UIImage *)makeImageRounded
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGRect rect =  CGRectMake(0, 0, self.size.width, self.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.size.width*0.5] addClip];

    [self drawInRect:rect];

    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultingImage;
}

@end

