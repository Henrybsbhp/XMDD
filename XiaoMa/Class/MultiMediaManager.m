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

/// 首先去缓存中查找，如果没有找到，就用DefaultPic替代，同时根据URL去网络下载，如果没有下载到，不再返回新的next。
- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withDefaultPic:(NSString *)picName;
{
    /// tmcache url长度超过239，导致存取失败
    NSString * cacheKey = urlKey;
    if (cacheKey.length > 239)
    {
        cacheKey = [cacheKey substringFromIndex:urlKey.length - 239];
    }
    
    if (cacheKey.length == 0)
    {
        return [RACSignal return:[UIImage imageNamed:picName]];
    }
    
    //
    RACScheduler *sch = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    RACSignal *signal = [[RACSignal startEagerlyWithScheduler:sch block:^(id<RACSubscriber> subscriber) {
        

        UIImage *img = [self.picCache imageForKey:cacheKey];
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
            UIImage * image = [UIImage imageNamed:picName];
            defaultSignal = [RACSignal return:image];
        }
        
        RACSignal * downloadOpSig = [DownloadOp firstDownloadOpInClientForReqURI:urlKey].rac_curSignal;
        if (!downloadOpSig)
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
                [self.picCache setImage:img forKey:cacheKey];
                
            }
            return img;
            
        }] catch:^RACSignal *(NSError *error) {
            
            return [RACSignal empty];
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
    
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"拍照",@"从相册选择"]
                                                                buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *section2 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"]
                                                                buttonStyle:JGActionSheetButtonStyleCancel];
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[section1, section2]];
    [sheet showInView:view animated:YES];
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        [sheet dismissAnimated:YES];
        if (indexPath.section != 0) {
            [subject sendCompleted];
        }
        //拍照
        else if (indexPath.row == 0)
        {
            if ([UIImagePickerController isFrontCameraAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.customObject = subject;
                controller.delegate = self;
                controller.allowsEditing = NO;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
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
        else if (indexPath.row == 1)
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
