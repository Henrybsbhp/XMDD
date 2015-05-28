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

- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withDefaultPic:(NSString *)picName
{
    return [self rac_getPictureForUrl:urlKey withDefaultPic:picName errorPic:picName];
}

- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withType:(ImageURLType)type
                         defaultPic:(NSString *)defPicName errorPic:(NSString *)errPicName
{
    if (type == ImageURLTypeThumbnail) {
        urlKey = [urlKey append:@"?imageView2/1/w/128/h/128"];
    }
    else if (type == ImageURLTypeMedium) {
        urlKey = [urlKey append:@"?imageView2/0/w/1024/h/1024"];
    }
    return [self rac_getPictureForUrl:urlKey withDefaultPic:defPicName errorPic:errPicName];
}

/// 首先去缓存中查找，如果没有找到，就用DefaultPic替代，同时根据URL去网络下载，如果没有下载到，不再返回新的next。
- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withDefaultPic:(NSString *)defPicName errorPic:(NSString *)errPicName
{
    /// tmcache url长度超过239，导致存取失败
    NSString * cacheKey = urlKey;
    if (cacheKey.length > 239)
    {
        cacheKey = [cacheKey substringFromIndex:urlKey.length - 239];
    }
    
    if (cacheKey.length == 0)
    {
        return [RACSignal return:[UIImage imageNamed:defPicName]];
    }
    
    //
    RACScheduler *sch = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    RACSignal *signal = [[RACSignal startEagerlyWithScheduler:sch block:^(id<RACSubscriber> subscriber) {
        
        UIImage *img = [UIImage imageWithData:[self.picCache objectForKey:cacheKey]];
        [subscriber sendNext:img];
        [subscriber sendCompleted];
    }] replay];

    signal = [signal flattenMap:^RACStream *(UIImage *img) {
    
        RACSignal * defaultSignal ;
        
        if (img)
        {
            return [RACSignal return:img];
        }
        else
        {
            /// @fq 
            UIImage * image = [UIImage imageNamed:defPicName];
            defaultSignal = [RACSignal return:image];
        }
        
        DownloadOp * duplicateOp = [DownloadOp firstDownloadOpInClientForReqURI:urlKey];
        RACSignal * downloadOpSig = duplicateOp.rac_curSignal;
        if (!duplicateOp)
        {
            DownloadOp * op = [DownloadOp operation];
            op.req_uri = urlKey;
            downloadOpSig = [op rac_getRequest];
        }
        
        downloadOpSig = [[downloadOpSig map:^id(DownloadOp *op) {
            
            UIImage *img = nil;
            if (op.rsp_data)
            {
                img = [UIImage imageWithData:op.rsp_data];
                [self.picCache setObject:op.rsp_data forKey:cacheKey block:nil];
            }
            return img;
            
        }] catch:^RACSignal *(NSError *error) {
            
            UIImage *img = [UIImage imageNamed:errPicName];
            return [RACSignal return:img];
        }];
        
        if (!downloadOpSig)
        {
            return defaultSignal;
        }
        
        return [defaultSignal merge:downloadOpSig];
    }];
    
    return [signal deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)rac_pickPhotoInTargetVC:(UIViewController *)targetVC inView:(UIView *)view
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
