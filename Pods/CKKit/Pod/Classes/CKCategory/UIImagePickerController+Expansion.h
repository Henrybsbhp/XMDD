//
//  UIImagePickerController+Expansion.h
//  JTReader
//
//  Created by jiangjunchen on 14-1-17.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController (Expansion)
+ (BOOL)isCameraAvailable;

+ (BOOL)isRearCameraAvailable;

+ (BOOL)isFrontCameraAvailable;

+ (BOOL)doesCameraSupportTakingPhotos;

+ (BOOL)isPhotoLibraryAvailable;

+ (BOOL)canUserPickVideosFromPhotoLibrary;

+ (BOOL)canUserPickPhotosFromPhotoLibrary;

+ (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;
@end
