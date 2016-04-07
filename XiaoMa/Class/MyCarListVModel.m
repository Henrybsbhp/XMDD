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
            desc = @"行驶证已认证通过";
            break;
        case 3:
            desc = @"请重新上传行驶证";
            break;
        default: {
            desc = @"上传行驶证送大礼";
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
            title = @"审核中";
            desc = @"已上传行驶证";
            break;
        case 2:
            title = @"已认证";
            desc = @"行驶证已认证通过";
            break;
        case 3:
            title = @"重新上传";
            btn.userInteractionEnabled = YES;
            enable = YES;
            [btn setCornerRadius:5 withBorderColor:HEXCOLOR(@"#18D06A") borderWidth:0.5];
            desc = [NSString stringWithFormat:@"认证未通过，%@", car.failreason.length > 0 ? car.failreason : @"请重新上传行驶证"];
            break;
        default:
            title = @"一键上传";
            btn.userInteractionEnabled = YES;
            enable = YES;
            [btn setCornerRadius:5 withBorderColor:HEXCOLOR(@"#18D06A") borderWidth:0.5];
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

@end
