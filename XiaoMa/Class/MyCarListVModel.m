//
//  MyCarListVModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyCarListVModel.h"
#import "UploadFileOp.h"
#import "EditPictureViewController.h"

@implementation MyCarListVModel

- (void)setupUploadBtn:(UIButton *)btn andDescLabel:(UILabel *)label forCar:(HKMyCar *)car
{
    btn.userInteractionEnabled = NO;
    NSString *bgName = @"mec_btn_bg3";
    NSString *title;
    NSString *desc;
    switch (car.status) {
        case 1:
            title = @"审核中";
            desc = @"行驶证已提交审核";
            break;
        case 2:
            title = @"审核成功";
            desc = @"车辆已通过认证";
            break;
        case 3:
            title = @"一键上传";
            btn.userInteractionEnabled = YES;
            desc = @"审核未通过,请重新上传行驶证";
            bgName = @"mec_btn_bg2";
            break;
        default:
            title = @"一键上传";
            btn.userInteractionEnabled = YES;
            desc = @"上传行驶证并通过审核,即可享受价值1000元的大礼包";
            bgName = @"mec_btn_bg2";
            break;
    }
    [btn setTitle:title forState:UIControlStateNormal];
    UIImage *bgimg = [[UIImage imageNamed:bgName] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 5, 9, 5)];
    [btn setBackgroundImage:bgimg forState:UIControlStateNormal];
    label.text = desc;
}

- (RACSignal *)rac_uploadDrivingLicenseWithTargetVC:(UIViewController *)targetVC initially:(void(^)(void))block
{
    RACSignal *signal = [[gAppMgr.mediaMgr rac_pickAndCropPhotoInTargetVC:targetVC inView:targetVC.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        CKAsyncMainQueue(^{
            if (block) {
                block();
            }
        });
        UploadFileOp *op = [UploadFileOp new];
//        img = [EditPictureViewController generateImageByAddingWatermarkWith:img];
        NSData *data = UIImageJPEGRepresentation(img, 0.5);
        op.req_fileDataArray = [NSArray arrayWithObject:data];
        op.req_fileType = @"jpg";
        return [[op rac_postRequest] map:^id(UploadFileOp *rspOp) {
            return [rspOp.rsp_urlArray safetyObjectAtIndex:0];
        }];

    }];
    return signal;
}

@end
