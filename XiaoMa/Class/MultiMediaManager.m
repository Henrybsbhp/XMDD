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
#import "JGActionSheet.h"
#import "UIImage+Utilities.h"
#import "EditPictureViewController.h"
#import <SDWebImageManager.h>

#define kPicCacheName    @"MultiMediaManager_PicCache"

@interface MultiMediaManager()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate>
@property (nonatomic, weak) UINavigationController *imgPickerNavCtrl;
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

- (RACSignal *)rac_getImageByUrl:(NSString *)strurl withType:(ImageURLType)type
                      defaultPic:(NSString *)defName errorPic:(NSString *)errName
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *url = strurl ? [NSURL URLWithString:strurl] : nil;
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

#pragma mark - ImagePicker
- (RACSignal *)rac_pickAndCropPhotoInTargetVC:(UIViewController *)targetVC inView:(UIView *)view
{
    RACSubject *subject = [RACSubject subject];
    __block BOOL picked = NO;
    
    [[self rac_pickPhotoInTargetVC:targetVC inView:view initBlock:^(UIImagePickerController *picker) {
       
        picker.customInfo[kImagePickerDelayDismiss] = @YES;
        picker.customInfo[kImagePickerCompressSize] = [NSValue valueWithCGSize:CGSizeMake(2048, 2048)];
    }] subscribeNext:^(UIImage *img) {
        
        picked = YES;
        EditPictureViewController *vc = [[EditPictureViewController alloc] init];
        vc.delegate = self;
        vc.rotationEnabled = NO;
        vc.image = img;
        vc.customObject = subject;
        [self.imgPickerNavCtrl pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        [subject sendCompleted];
    } completed:^{
        if (!picked) {
            [subject sendCompleted];
        }
    }];
    return subject;
}

- (RACSignal *)rac_pickPhotoInTargetVC:(UIViewController *)targetVC
                                inView:(UIView *)view
{
    return [self rac_pickPhotoInTargetVC:targetVC inView:view initBlock:^(UIImagePickerController *picker) {
        picker.customInfo[kImagePickerCompressSize] = [NSValue valueWithCGSize:CGSizeMake(1024, 1024)];
    }];
}

- (RACSignal *)rac_pickPhotoInTargetVC:(UIViewController *)targetVC
                                inView:(UIView *)view initBlock:(void (^)(UIImagePickerController *))block
{
    RACSubject *subject = [RACSubject subject];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选取照片" delegate:nil cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [sheet showInView:view];
    [[sheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
        NSInteger index = [x integerValue];
        //拍照
        if (index == 0)
        {
            if ([UIImagePickerController isCameraAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.customObject = subject;
                controller.delegate = self;
                controller.allowsEditing = NO;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                if (block) {
                    block(controller);
                }
                [targetVC presentViewController:controller animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该设备不支持拍照" message:nil delegate:nil
                                                      cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [subject sendCompleted];
            }
        }
        // 从相册中选取
        else if (index == 1)
        {
            if ([UIImagePickerController isPhotoLibraryAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.customObject = subject;
                controller.delegate = self;
                controller.allowsEditing = NO;
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                if (block) {
                    block(controller);
                }
                [targetVC presentViewController:controller animated:YES completion:nil];
            }
            else {
                [subject sendCompleted];
            }
        }
    }];
    return subject;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL editing = picker.allowsEditing;
    BOOL delayDismiss = [picker.customInfo[kImagePickerDelayDismiss] boolValue];
    NSValue *sizeValue = picker.customInfo[kImagePickerCompressSize];
    if (!delayDismiss) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
    UIImage *img = [info objectForKey:editing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage];
    if (sizeValue) {
        img = [img compressImageWithPixelSize:[sizeValue CGSizeValue]];
    }
    RACSubject *subject = picker.customObject;
    [subject sendNext:img];
    [subject sendCompleted];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    RACSubject *subject = picker.customObject;
    [subject sendCompleted];
}

#pragma mark - PECropViewControllerDelegate
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    RACSubject *subject = controller.customObject;
    [controller dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [EditPictureViewController generateImageByAddingWatermarkWith:croppedImage];
    [subject sendNext:image];
    [subject sendCompleted];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    RACSubject *subject = controller.customObject;
    [controller dismissViewControllerAnimated:YES completion:nil];
    [subject sendCompleted];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.imgPickerNavCtrl = navigationController;
}

@end
