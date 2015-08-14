//
//  SubmitInsuranceInfoVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/25.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "SubmitInsuranceInfoVC.h"
#import "JGActionSheet.h"
#import "EditPictureViewController.h"
#import "UIView+Shake.h"
#import "UploadFileOp.h"
#import "UpdateInsuranceCalculateOp.h"

@interface SubmitInsuranceInfoVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *idCardContainerView;
@property (weak, nonatomic) IBOutlet UITextField *idCardField;
@property (weak, nonatomic) IBOutlet UIView *defaultPhotoView;
@property (weak, nonatomic) IBOutlet UIImageView *pickedPhotoView;
@property (nonatomic, strong) UIImage *pickedPhoto;
@property (nonatomic, strong) NSString *pickedPhotoUrl;
@property (nonatomic, weak) UINavigationController *imgPickerNavCtrl;

@end

@implementation SubmitInsuranceInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.idCardField.delegate = self;
    [self reloadDrivingCard];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp124"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp124"];
}

- (void)dealloc
{
    DebugLog(@"SubmitInsuranceInfoVC dealloc");
}

- (void)reloadDrivingCard
{
    self.pickedPhotoUrl = self.car.licenceurl;
    if (self.pickedPhotoUrl.length > 0) {
//        [[gAppMgr.mediaMgr rac_getPictureForUrl:self.pickedPhotoUrl withType:ImageURLTypeOrigin defaultPic:@"cm_defpic" errorPic:@"cm_defpic_fail"] subscribeNext:^(UIImage *x) {
//            
//            self.pickedPhoto = x;
//            self.pickedPhotoView.image = x;
//            self.defaultPhotoView.hidden = YES;
//        }];
        
        self.pickedPhotoView.image = [UIImage imageNamed:@"cm_defpic"];
        self.defaultPhotoView.hidden = YES;
        [[gAppMgr.mediaMgr rac_getPictureForUrl:self.pickedPhotoUrl defaultPic:nil] subscribeNext:^(UIImage *orgImg) {
            if (!orgImg) {
                self.pickedPhotoView.image = [UIImage imageNamed:@"cm_defpic"];
                return ;
            }
            self.pickedPhoto = orgImg;
            NSString *markedUrl = [self.pickedPhotoUrl append:@"_marked"];
            [[[gAppMgr.mediaMgr rac_getImageFromCacheWithUrl:markedUrl] deliverOn:[RACScheduler mainThreadScheduler]]
             subscribeNext:^(UIImage *markedImg) {
                if (!markedImg) {
                    markedImg = [EditPictureViewController generateImageByAddingWatermarkWith:orgImg];
                    [gAppMgr.mediaMgr.picCache setImage:markedImg forKey:markedUrl];
                }
                self.pickedPhotoView.image = markedImg;
            }];
        } error:^(NSError *error) {
            self.pickedPhotoView.image = [UIImage imageNamed:@"cm_defpic_fail"];
        }];
    }
}

#pragma mark - Textfield
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [MobClick event:@"rp124-1"];
}

#pragma mark - Action
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionTakePhoto:(id)sender {
    
    [MobClick event:@"rp124-2"];
    if (self.pickedPhotoUrl.length > 0) {
        return;
    }

    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"拍照",@"从相册选择"]
                                                                buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *section2 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"]
                                                                buttonStyle:JGActionSheetButtonStyleCancel];
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[section1, section2]];
    sheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [sheet showInView:self.navigationController.view animated:YES];
    
    CGFloat boundWidth = self.navigationController.view.bounds.size.width;
    CGFloat boundHeight = sheet.frame.size.height - sheet.scrollViewHost.frame.size.height;
    CGRect frame = CGRectMake(0, 0, boundWidth, boundHeight);

    UIView *exampleView = [[UIView alloc] initWithFrame:frame];
    exampleView.backgroundColor = [UIColor clearColor];
    
    //显示水印的例子图片
    frame = CGRectMake((frame.size.width-290)/2, (frame.size.height-230)/2, 290, 230);
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:frame];
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *img = nil;//self.pickedPhoto;
    img = [img isKindOfClass:[UIImage class]] ? img : [UIImage imageNamed:@"ins_pic2"];
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
    [exampleView setHidden:NO animated:YES];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
        
        [exampleView setHidden:YES animated:YES];
        [sheet dismissAnimated:YES];
        if (sheetIndexPath.section != 0) {
            [MobClick event:@"rp124-6"];
            return ;
        }
        
        //拍照
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0)
        {
            [MobClick event:@"rp124-4"];
            if ([UIImagePickerController isCameraAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = NO;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                [self presentViewController:controller animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该设备不支持拍照" message:nil delegate:nil
                                                      cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }
        // 从相册中选取
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1)
        {
            [MobClick event:@"rp124-5"];
            if ([UIImagePickerController isPhotoLibraryAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = NO;
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    }];

}

- (IBAction)actionSubmit:(id)sender {
    
    [MobClick event:@"rp124-3"];
    if (self.idCardField.text.length != 18) {
        [gToast showText:@"请填写正确的身份证号码"];
        [self.idCardContainerView shake];
        return;
    }
    if (self.pickedPhotoUrl.length == 0 && self.pickedPhoto == nil) {
        [gToast showText:@"请提供行驶证正面照片"];
        return;
    }
    
    [self.view endEditing:YES];
    RACSignal *signal;
    //获取行驶证url
    if (self.pickedPhotoUrl.length == 0) {
        UploadFileOp *op = [UploadFileOp new];
        op.req_fileType = @"jpg";
        [op setFileArray:@[self.pickedPhoto] withGetDataBlock:^NSData *(UIImage *img) {
            return UIImageJPEGRepresentation(img, 0.5);
        }];
        signal = [[op rac_postRequest] map:^id(UploadFileOp *op) {
            return [op.rsp_urlArray safetyObjectAtIndex:0];
        }];
    } else {
        signal = [RACSignal return:self.pickedPhotoUrl];
    }

    //提交询价资料
    signal = [signal flattenMap:^RACStream *(NSString *url) {
        
        UpdateInsuranceCalculateOp *op = [UpdateInsuranceCalculateOp new];
        op.req_cid = self.calculateID;
        op.req_idcard = self.idCardField.text;
        op.req_driverpic = url;
        return [op rac_postRequest];
    }];
    
    //更新车辆信息
    signal = [signal flattenMap:^RACStream *(UpdateInsuranceCalculateOp *op) {
        
        MyCarsModel *model = gAppMgr.myUser.carModel;
        
        RACSignal *sig;
        if (!model) {
            return [RACSignal return:@0];
        }
        //添加车辆
        else if (self.shouldUpdateCar && self.car.carId == nil) {
            self.car.licenceurl = op.req_driverpic;
            self.car.status = 1;
            sig = [[model rac_addCar:self.car] map:^id(id value) {
                return @1;
            }];
        }
        //如果行驶证不一样且未审核，则更新车辆
        else if (![op.req_driverpic equalByCaseInsensitive:self.car.licenceurl] &&
                 self.car.status != 1 &&
                 self.car.status != 2) {
            self.car.licenceurl = op.req_driverpic;
            self.car.status = 1;
            sig = [[model rac_updateCar:self.car] map:^id(id value) {
                return @2;
            }];
        }
        //更新车辆
        else if (self.shouldUpdateCar) {
            sig = [[model rac_updateCar:self.car] map:^id(id value) {
                return @2;
            }];
        }
        if (sig) {
            return [sig catch:^RACSignal *(NSError *error) {
                return [RACSignal return:@0];
            }];
        }
        return [RACSignal return:@0];
    }];

    [[signal initially:^{
        
        [gToast showingWithText:@"正在上传..."];
    }] subscribeNext:^(id x) {
        
        [gToast dismiss];
        NSInteger status = [x integerValue];
        NSString *msg;
        if (status == 1) {
            msg = @"该车辆已保存至爱车信息中，工作人员将于1个工作日内为您精准报价";
        }
        else if (status == 2) {
            msg = @"该爱车信息已更新，工作人员将于1个工作日内为您精准报价";
        }
        else {
            msg = @"工作人员将于1个工作日内为您精准报价";
        }
        UIAlertView *alert = [[UIAlertView alloc] initNoticeWithTitle:@"上传成功" message:msg cancelButtonTitle:@"确定"];
        [alert show];
        [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
            if (self.originVC) {
                [self.navigationController popToViewController:self.originVC animated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //图片压缩成jpg
    UIImage *portraitImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    EditPictureViewController *vc = [[EditPictureViewController alloc] init];
    vc.delegate = self;
    vc.image = portraitImg;
    CGFloat width = portraitImg.size.width;
    CGFloat height = portraitImg.size.height;
    CGFloat length = MIN(width, height);
    vc.imageCropRect = CGRectMake((width - length) / 2,
                                  (height - length) / 2,
                                  length,
                                  length);
    [self.imgPickerNavCtrl pushViewController:vc animated:YES];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PECropViewControllerDelegate
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    croppedImage = [croppedImage compressImageWithPixelSize:CGSizeMake(2048, 2048)];
    UIImage *image = [EditPictureViewController generateImageByAddingWatermarkWith:croppedImage];
    self.pickedPhoto = croppedImage;
    self.pickedPhotoUrl = nil;
    self.pickedPhotoView.image = image;
    self.defaultPhotoView.hidden = YES;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.imgPickerNavCtrl = navigationController;
}

@end
