//
//  UploadInfomationVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UploadInfomationVC.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "XiaoMa.h"
#import "JGActionSheet.h"
#import "UploadFileOp.h"
#import "WebVC.h"
#import "UpdateInsuranceCalculateOp.h"

@interface UploadInfomationVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *datasource;
@end

@implementation UploadInfomationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadDatasource
{
    self.datasource = [NSMutableArray arrayWithArray:@[@NO,@NO,@NO]];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionHelp:(id)sender
{
    WebVC *vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionUpload:(id)sender
{
    if (![[self.datasource safetyObjectAtIndex:0] isKindOfClass:[UIImage class]]) {
        [gToast showText:@"请提供身份证照片"];
        return;
    }
    if (![[self.datasource safetyObjectAtIndex:1] isKindOfClass:[UIImage class]]) {
        [gToast showText:@"请提供行驶证正面照片"];
        return;
    }
    if (![[self.datasource safetyObjectAtIndex:2] isKindOfClass:[UIImage class]]) {
        [gToast showText:@"请提供行驶证副本照片"];
        return;
    }
    UploadFileOp *op = [UploadFileOp new];
    op.req_fileType = @"jpg";
    [op setFileArray:self.datasource withGetDataBlock:^NSData *(UIImage *img) {
        return UIImageJPEGRepresentation(img, 1.0);
    }];
    
    [[[[op rac_postRequest] flattenMap:^RACStream *(UploadFileOp *uploadOp) {
        UpdateInsuranceCalculateOp *op = [UpdateInsuranceCalculateOp new];
        op.req_cid = self.calculateID;
        op.req_idpic = [uploadOp.rsp_urlArray safetyObjectAtIndex:0];
        op.req_driverpic = [uploadOp.rsp_urlArray safetyObjectAtIndex:1];
        op.req_drivercopypic = [uploadOp.rsp_urlArray safetyObjectAtIndex:2];
        return [op rac_postRequest];
    }] initially:^{
        [gToast showingWithText:@"正在上传..."];
    }] subscribeNext:^(id x) {
        [gToast dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initNoticeWithTitle:@"上传成功" message:@"小马达达客户人员会尽快和您联系" cancelButtonTitle:@"确定"];
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
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UIView *container1 = (UIView *)[cell.contentView viewWithTag:100];
    UIImageView *imgV2 = (UIImageView *)[cell.contentView viewWithTag:1002];
    
    UIImage *img = [self.datasource safetyObjectAtIndex:indexPath.row];
    if ([img isKindOfClass:[UIImage class]]) {
        container1.hidden = YES;
        imgV2.hidden = NO;
        imgV2.image = img;
    }
    else {
        container1.hidden = NO;
        imgV2.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
//    UIView *exampleView = [[UIView alloc] initWithFrame:CGRectMake((boundWidth-280)/2, (boundHeight-224)/2+30, 280, 224)];
    UIView *exampleView = [[UIView alloc] initWithFrame:frame];
    exampleView.backgroundColor = [UIColor clearColor];
    
    //显示水印的例子图片
    frame = CGRectMake((frame.size.width-290)/2, (frame.size.height-230)/2, 290, 230);
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:frame];
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *img = [self.datasource safetyObjectAtIndex:indexPath.row];
    img = [img isKindOfClass:[UIImage class]] ? img : [UIImage imageNamed:[NSString stringWithFormat:@"ins_pic%d",
                                                                           (int)indexPath.row+1]];
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
    label.text = @"所有上传资料均会加水印，小马达达保障您的安全！";
    
    [exampleView addSubview:imgV];
    [exampleView addSubview:label];
    exampleView.hidden = YES;
    [sheet addSubview:exampleView];
    [exampleView setHidden:NO animated:YES];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
        
        [exampleView setHidden:YES animated:YES];
        [sheet dismissAnimated:YES];
        //拍照
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0)
        {
            if ([UIImagePickerController isFrontCameraAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = YES;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.customObject = indexPath;
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
            if ([UIImagePickerController isPhotoLibraryAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = YES;
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.customObject = indexPath;
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    }];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *portraitImg = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *resultImg = [self addWatermarkForImage:portraitImg];
    NSIndexPath *indexPath = picker.customObject;
    [self.datasource safetyReplaceObjectAtIndex:indexPath.row withObject:resultImg];
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utility
- (UIImage *)addWatermarkForImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    if (image.size.width > 0 && image.size.height/image.size.height < 0.8) {
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeft];
    }
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

@end
