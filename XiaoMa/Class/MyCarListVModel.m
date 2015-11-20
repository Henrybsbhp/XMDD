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

@implementation MyCarListVModel
- (NSString *)descForCarStatus:(HKMyCar *)car
{
    NSString *desc;
    switch (car.status) {
        case 1:
            desc = @"行驶证已提交审核 \n一般一个工作日内审核完毕";
            break;
        case 2:
            desc = @"车辆已通过认证";
            break;
        case 3:
            desc = [NSString stringWithFormat:@"审核未通过，%@", car.failreason.length > 0 ? car.failreason : @"请重新上传行驶证"];
            break;
        default:
            desc = @"上传行驶证并通过审核,即可享受价值1000元的大礼包";
            break;
    }
    return desc;
}

- (void)setupUploadBtn:(UIButton *)btn andDescLabel:(UILabel *)label forCar:(HKMyCar *)car
{
    btn.userInteractionEnabled = NO;
    NSString *title;
    NSString *desc = [self descForCarStatus:car];
    BOOL enable = NO;
    switch (car.status) {
        case 1:
            title = @"审核中";
            break;
        case 2:
            title = @"审核成功";
            break;
        case 3:
            title = @"重新上传";
            btn.userInteractionEnabled = YES;
            enable = YES;
            break;
        default:
            title = @"一键上传";
            btn.userInteractionEnabled = YES;
            enable = YES;
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
        op.req_fileType = UploadFileTypeDrivingLicense;
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

@end
