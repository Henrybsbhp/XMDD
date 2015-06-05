//
//  UIImagePickerController+Expansion.m
//  JTReader
//
//  Created by jiangjunchen on 14-1-17.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "UIImagePickerController+Expansion.h"
#import <MobileCoreServices/UTCoreTypes.h>
@implementation UIImagePickerController (Expansion)
#pragma mark camera utility
+ (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL)isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL)isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (BOOL)doesCameraSupportTakingPhotos
{
    return [UIImagePickerController cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
                          sourceType:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL)isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
+ (BOOL)canUserPickVideosFromPhotoLibrary
{
    return [UIImagePickerController cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie
                                             sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL)canUserPickPhotosFromPhotoLibrary
{
    return [UIImagePickerController cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
                                             sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0)
    {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType])
        {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
@end
