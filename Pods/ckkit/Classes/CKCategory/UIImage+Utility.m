//
//  UIImage+Utility.m
//  JTReader
//
//  Created by jiangjunchen on 14-1-17.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

@implementation UIImage (Utility)
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
                                                8, 0, colorSpaceInfo, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
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
    NSLog(@"%@",NSStringFromCGSize(thumbnail.size));
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);

    return thumbnail;
}

-(UIImage *)addImage:(UIImage *)image1 edgeInsets:(UIEdgeInsets)insets
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    //Draw image2
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    //Draw image1
    [image1 drawInRect:CGRectMake(insets.left, insets.top,
                                  self.size.width-insets.left-insets.right,
                                  self.size.height-insets.top-insets.bottom)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}


- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)imageWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat * startColorComponents = (CGFloat *)CGColorGetComponents([startColor CGColor]);
    CGFloat * endColorComponents = (CGFloat *)CGColorGetComponents([endColor CGColor]);
    
    CGFloat colorComponents[8] = {
        startColorComponents[0],
        startColorComponents[1],
        startColorComponents[2],
        startColorComponents[3],
        
        endColorComponents[0],
        endColorComponents[1],
        endColorComponents[2],
        endColorComponents[3]
    };
    
    CGFloat colorIndices[2] = {0.0f,1.0f};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, (const CGFloat *)&colorComponents, (const CGFloat *)&colorIndices, 2);
    CGColorSpaceRelease(colorSpace);
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGPoint startPoint, endPoint;
    startPoint = CGPointMake(0.0f, screenBounds.size.height/2.0f);
    endPoint = CGPointMake(screenBounds.size.width, startPoint.y);
    
    
    UIGraphicsBeginImageContext(size);
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient , startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
