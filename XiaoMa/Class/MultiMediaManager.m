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

#define kPicCacheName    @"MultiMediaManager_PicCache"

@interface MultiMediaManager()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation MultiMediaManager

static MultiMediaManager *g_mediaManager;

- (instancetype)initWithPicCache:(TMCache *)cache
{
    self = [super init];
    if (self) {
        _picCache = cache;
    }
    return self;
}

- (RACSignal *)rac_getPictureForUrl:(NSString *)url withType:(ImageURLType)type
                           defaultPic:(NSString *)defName errorPic:(NSString *)errName
{
    return [[self rac_getPictureForUrl:url withType:type defaultPic:defName] catch:^RACSignal *(NSError *error) {
        if (errName.length > 0) {
            return [RACSignal return:[UIImage imageNamed:errName]];
        }
        return [RACSignal error:error];
    }];
}

- (RACSignal *)rac_getPictureForUrl:(NSString *)url withType:(ImageURLType)type defaultPic:(NSString *)defName
{
    if (type == ImageURLTypeThumbnail) {
        url = [url append:@"?imageView2/1/w/128/h/128"];
    }
    else if (type == ImageURLTypeMedium) {
        url = [url append:@"?imageView2/0/w/1024/h/1024"];
    }
    return [self rac_getPictureForUrl:url defaultPic:defName];
}

- (RACSignal *)rac_getPictureForUrl:(NSString *)url defaultPic:(NSString *)defName
{
    RACSignal *signal = [self rac_getImageFromCacheWithUrl:url];
    //从网络获取image
    signal = [signal flattenMap:^RACStream *(UIImage *img) {

        if (img) {
            return [RACSignal return:img];
        }
        RACSignal *sig = [[self rac_getImageFromWebWithUrl:url] filter:^BOOL(id value) {
            return (BOOL)value;
        }];
        if (defName.length > 0) {
            sig = [sig merge:[RACSignal return:[UIImage imageNamed:defName]]];
        }
        return sig;
    }];
    
    return [signal deliverOn:[RACScheduler mainThreadScheduler]];
}

#pragma mark - Private Image Method
- (RACSignal *)rac_getImageFromCacheWithUrl:(NSString *)url
{
    RACScheduler *sch = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    //从本地缓存获取image
    RACSignal *signal = [[RACSignal startEagerlyWithScheduler:sch block:^(id<RACSubscriber> subscriber) {
        
        UIImage *img = [self.picCache imageForKey:url];
        [subscriber sendNext:img];
        [subscriber sendCompleted];
    }] replay];
    return signal;
}

- (RACSignal *)rac_getImageFromWebWithUrl:(NSString *)url
{
    DownloadOp *curOp = [DownloadOp firstDownloadOpInClientForReqURI:url];
    RACSignal * downloadSig = [curOp rac_curSignal];
    if (!downloadSig)
    {
        DownloadOp * op = [DownloadOp operation];
        op.req_uri = url;
        downloadSig = [op rac_getRequest];
    }
    
    return [downloadSig map:^id(DownloadOp *op) {
        UIImage *img;
        if (op.rsp_data) {
            
            [self.picCache.diskCache setFileData:op.rsp_data forKey:url];
            img = [UIImage imageWithData:op.rsp_data];
            [self.picCache.memoryCache setObject:img forKey:url];
        }
        return img;
    }];
}

#pragma mark - ImagePicker
- (RACSignal *)rac_pickPhotoInTargetVC:(UIViewController *)targetVC
                                inView:(UIView *)view
{
    return [self rac_pickPhotoInTargetVC:targetVC inView:view initBlock:nil];
}

- (RACSignal *)rac_pickPhotoInTargetVC:(UIViewController *)targetVC
                                inView:(UIView *)view initBlock:(void(^)(UIImagePickerController *picker))block
{
    RACSubject *subject = [RACSubject new];
    
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
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *compressedImg = [img compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    RACSubject *subject = picker.customObject;
    [subject sendNext:compressedImg];
    [subject sendCompleted];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    RACSubject *subject = picker.customObject;
    [subject sendCompleted];
}

@end
