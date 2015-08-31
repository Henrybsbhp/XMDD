//
//  UploadInsuranceInfoVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UploadInsuranceInfoVC.h"
#import "JGActionSheet.h"
#import "UIView+Shake.h"
#import "UploadFileOp.h"
#import "HKImagePicker.h"


@interface UploadInsuranceInfoVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *idCardContainerView;
@property (weak, nonatomic) IBOutlet UITextField *idCardField;
@property (weak, nonatomic) IBOutlet UIView *defaultPhotoView;
@property (weak, nonatomic) IBOutlet UIImageView *pickedPhotoView;
@property (nonatomic, strong) UIImage *pickedPhoto;
@property (nonatomic, strong) NSString *pickedPhotoUrl;
@property (nonatomic, weak) UINavigationController *imgPickerNavCtrl;
@end

@implementation UploadInsuranceInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.idCardField.delegate = self;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"SubmitInsuranceInfoVC dealloc");
}

#pragma mark - Textfield
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [MobClick event:@"rp124-1"];
}

#pragma mark - Action
- (IBAction)actionSkip:(id)sender
{
    if (self.getNextVCBlock) {
        UIViewController *nextVC = self.getNextVCBlock(YES);
        if (nextVC) {
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }
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
    
    @weakify(self);
    [[signal initially:^{
      
        [gToast showingWithText:@"正在上传..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        if (self.getNextVCBlock) {
            UIViewController *nextVC = self.getNextVCBlock(NO);
            if (nextVC) {
                [self.navigationController pushViewController:nextVC animated:YES];
            }
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - Utility
- (UIImage *)generateImageByAddingWatermarkWith:(UIImage *)croppedImage
{
    UIImage *image = [croppedImage compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    //Draw image
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    //Draw watermark
    UIImage *watermark = [UIImage imageNamed:@"cm_watermark"];
    CGFloat yoffset = ceil((image.size.height/image.size.width - watermark.size.height/watermark.size.width)*image.size.width/2.0);
    [watermark drawInRect:CGRectMake(0, yoffset, image.size.width, image.size.height - 2*yoffset)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //图片压缩
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *croppedImage = [image compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    image = [self generateImageByAddingWatermarkWith:croppedImage];
    self.pickedPhoto = croppedImage;
    self.pickedPhotoUrl = nil;
    self.pickedPhotoView.image = image;
    self.defaultPhotoView.hidden = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.imgPickerNavCtrl = navigationController;
}

@end
