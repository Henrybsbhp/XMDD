//
//  MyCarListVModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyCarListVModel.h"
#import "UploadFileOp.h"
#import "HKImagePicker.h"
#import "MyCarStore.h"
#import "UIView+RoundedCorner.h"
#import "JGActionSheet.h"

@interface MyCarListVModel () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation MyCarListVModel
- (NSString *)descForCarStatus:(HKMyCar *)car
{
    NSString *desc;
    switch (car.status) {
        case 1:
            desc = @"审核中";
            break;
        case 2:
            desc = @"已认证";
            break;
        case 3:
            desc = [NSString stringWithFormat:@"认证未通过，%@", car.failreason.length > 0 ? car.failreason : @"请重新上传行驶证"];
            break;
        default: {
            MyCarStore *store = [MyCarStore fetchExistsStore];
            if (store.defaultTip) {
                desc = store.defaultTip;
            }
            else {
                desc = @"未认证";
            }
        } break;
    }
    return desc;
}

- (NSString *)uploadButtonStateForCar:(HKMyCar *)car
{
    NSString *desc;
    switch (car.status) {
        case 1:
            desc = @"已上传行驶证";
            break;
        case 2:
            desc = @"已认证通过";
            break;
        case 3:
            desc = @"请重新上传";
            break;
        default: {
            desc = @"送千元礼包";
        } break;
    }
    return desc;
}

- (void)setupUploadBtn:(UIButton *)btn andDescLabel:(UILabel *)label forCar:(HKMyCar *)car
{
    //TODO
    NSString *title;
    NSString *desc;
    BOOL enable = NO;
    switch (car.status) {
        case 1:
            title = @"认证审核中...";
            desc = @"行驶证已提交审核";
            // 防止一键上传 -》审核中，边线还在的情况
            [btn setCornerRadius:0 withBorderColor:[UIColor clearColor] borderWidth:0.5];
            break;
        case 2:
            title = @"认证通过";
            desc = @"行驶证已认证通过";
            break;
        case 3:
            title = @"重新上传";
            btn.userInteractionEnabled = YES;
            enable = YES;
            [btn setCornerRadius:5 withBorderColor:kDefTintColor borderWidth:0.5];
            desc = [NSString stringWithFormat:@"认证未通过，%@", car.failreason.length > 0 ? car.failreason : @"请重新上传行驶证"];
            break;
        default:
            title = @"一键上传";
            btn.userInteractionEnabled = YES;
            enable = YES;
            [btn setCornerRadius:5 withBorderColor:kDefTintColor borderWidth:0.5];
            MyCarStore *store = [MyCarStore fetchExistsStore];
            if (store.defaultTip) {
                desc = store.defaultTip;
            }
            else {
                desc = @"未认证";
            }
            break;
    }
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateDisabled];
    btn.enabled = enable;
    label.text = desc;
}

- (RACSignal *)rac_uploadDrivingLicenseWithTargetVC:(UIViewController *)targetVC initially:(void(^)(void))block
{
    HKImagePicker *picker = [HKImagePicker imagePicker];
    picker.compressedSize = CGSizeMake(1024, 1024);
    RACSignal *signal = [[picker rac_pickImageInTargetVC:targetVC inView:targetVC.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        CKAsyncMainQueue(^{
            if (block) {
                block();
            }
        });
        UploadFileOp *op = [UploadFileOp new];
        op.req_fileType = UploadFileTypeDrivingLicenseAndOther;
//        img = [EditPictureViewController generateImageByAddingWatermarkWith:img];
        NSData *data = UIImageJPEGRepresentation(img, 0.5);
        op.req_fileDataArray = [NSArray arrayWithObject:data];
        op.req_fileExtType = @"jpg";
        return [[op rac_postRequest] map:^id(UploadFileOp *rspOp) {
            return [rspOp.rsp_urlArray safetyObjectAtIndex:0];
        }];
    }];
    return signal;
}

- (void)showImagePickerWithTargetVC:(UIViewController *)targetVC
{
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"拍照",@"从相册选择"]
                                                                buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *section2 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"]
                                                                buttonStyle:JGActionSheetButtonStyleCancel];
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[section1, section2]];
    sheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [sheet showInView:targetVC.navigationController.view animated:YES];
    
    CGFloat boundWidth = targetVC.navigationController.view.bounds.size.width;
    CGFloat boundHeight = sheet.frame.size.height - sheet.scrollViewHost.frame.size.height;
    CGRect frame = CGRectMake(0, 0, boundWidth, boundHeight);
    
    UIView *exampleView = [[UIView alloc] initWithFrame:frame];
    exampleView.backgroundColor = [UIColor clearColor];
    
    //显示水印的例子图片
    frame = CGRectMake((frame.size.width-290)/2, (frame.size.height-230)/2, 290, 230);
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:frame];
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *img = [UIImage imageNamed:@"ins_pic2"];
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
    
    [exampleView addSubview:imgV];
    [exampleView addSubview:label];
    exampleView.hidden = YES;
    [sheet addSubview:exampleView];
    [exampleView setHidden:NO animated:YES];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *rsheet, NSIndexPath *sheetIndexPath) {
        
        [exampleView setHidden:YES animated:YES];
        [rsheet dismissAnimated:YES];
        if (sheetIndexPath.section != 0) {
            return ;
        }
        
        //拍照
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0)
        {
            if ([UIImagePickerController isCameraAvailable])
            {
                if (![gPhoneHelper handleCameraAuthStatusDenied])
                {
                    return;
                }
                
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                [targetVC presentViewController:controller animated:YES completion:nil];
            }
            else
            {
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该设备不支持拍照" ActionItems:@[cancel]];
                [alert show];
            }
        }
        // 从相册中选取
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1)
        {
            if ([UIImagePickerController isPhotoLibraryAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = NO;
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                [targetVC presentViewController:controller animated:YES completion:nil];
            }
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //图片压缩
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *croppedImage = [image compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    
    UploadFileOp *op = [UploadFileOp new];
    op.req_fileType = UploadFileTypeDrivingLicenseAndOther;
    NSData *data = UIImageJPEGRepresentation(croppedImage, 0.5);
    op.req_fileDataArray = [NSArray arrayWithObject:data];
    op.req_fileExtType = @"jpg";
    RACSignal *signal = [[op rac_postRequest] map:^id(UploadFileOp *rspOp) {
        return [rspOp.rsp_urlArray safetyObjectAtIndex:0];
    }];
    if (self.imagePickerBlock) {
        self.imagePickerBlock(signal);
    }
}

@end
