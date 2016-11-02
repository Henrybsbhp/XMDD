//
//  ImagePickerVC.m
//  XMDD
//
//  Created by jiangjunchen on 16/10/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ImagePickerVC.h"
#import "JGActionSheet.h"
#import "UIImage+Utilities.h"

@interface ImagePickerVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIView *exampleView;
@end

@implementation ImagePickerVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.exampleTitle = @"所有上传资料均会加水印，小马达达保障您的隐私安全！";
        self.shouldShowExample = YES;
        self.shouldCompressImage = YES;
    }
    return self;
}

- (void)show {
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"拍照",@"从相册选择"]
                                                                buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *section2 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"]
                                                                buttonStyle:JGActionSheetButtonStyleCancel];
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[section1, section2]];
    sheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [sheet showInView:self.targetVC.view animated:YES];
    
    CGFloat boundWidth = self.targetVC.view.bounds.size.width;
    CGFloat boundHeight = sheet.frame.size.height - sheet.scrollViewHost.frame.size.height;
    CGRect frame = CGRectMake(0, 0, boundWidth, boundHeight);

    if (self.shouldShowExample) {
        [self showExampleViewWithFrame:frame inActionSheet:sheet];
    }
    
    [sheet setButtonPressedBlock:^(JGActionSheet *rsheet, NSIndexPath *sheetIndexPath) {
        
        [self.exampleView setHidden:YES animated:YES];
        [rsheet dismissAnimated:YES];
        if (sheetIndexPath.section != 0) {
            return ;
        }
        
        //拍照
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0) {
            if ([UIImagePickerController isCameraAvailable]) {
                if (![gPhoneHelper handleCameraAuthStatusDenied]) {
                    return;
                }
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = NO;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.customObject = self;
                [self.targetVC presentViewController:controller animated:YES completion:nil];
            } else {
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该设备不支持拍照" ActionItems:@[cancel]];
                [alert show];
            }
        }
        // 从相册中选取
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1) {
            if ([UIImagePickerController isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = NO;
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.customObject = self;
                [self.targetVC presentViewController:controller animated:YES completion:nil];
            }
        }
    }];
}

- (void)showExampleViewWithFrame:(CGRect)frame inActionSheet: (JGActionSheet *)sheet {
    
    //显示水印的例子图片
    UIView *exampleView = [[UIView alloc] initWithFrame:frame];
    exampleView.backgroundColor = [UIColor clearColor];

    frame = CGRectMake((frame.size.width-290)/2, (frame.size.height-230)/2, 290, 230);
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:frame];
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *img = self.exampleImage;
    imgV.image = img;
    CGFloat offset = 0;
    if (img.size.width > 0) {
        offset = MIN(0, -ceil((frame.size.height - img.size.height/img.size.width*frame.size.width)/2.0));
    }
    frame =  CGRectMake(frame.origin.x-5, CGRectGetMaxY(frame)+5+offset, frame.size.width+10, 40);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.text = @"所有上传资料均会加水印，小马达达保障您的隐私安全！";
    
    [exampleView addSubview:imgV];
    [exampleView addSubview:label];
    exampleView.hidden = YES;
    [sheet addSubview:exampleView];
    
    self.exampleView = exampleView;
    [self.exampleView setHidden:NO animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //图片压缩
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.shouldCompressImage) {
        UIImage *compressedImage = [image compressImageWithPixelSize:CGSizeMake(1024, 1024)];
        if (self.completedBlock) {
            self.completedBlock(compressedImage);
        }
    }
    else {
        if (self.completedBlock) {
            self.completedBlock(info);
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
