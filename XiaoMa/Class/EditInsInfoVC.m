//
//  EditInsInfoVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "EditInsInfoVC.h"
#import "JGActionSheet.h"
#import "PickInsCompaniesVC.h"

@interface EditInsInfoVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImage * idImage;

@end

@implementation EditInsInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 12, 0, 0)];
    headerLabel.textColor = HEXCOLOR(@"#888888");
    headerLabel.font = [UIFont systemFontOfSize:16];
    if (section == 0) {
        headerLabel.text = @"请上传车主身份证照片";
    }
    else if (section == 1) {
        headerLabel.text = @"请上传车主行驶证照片";
    }
    else {
        headerLabel.text = @"请选择保险公司";
    }
    [headerLabel sizeToFit];
    [view addSubview:headerLabel];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 15;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 166;
    }
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 || indexPath.section == 1) {
        cell = [self sImageCellAtIndexPath:indexPath];
    }
    else {
        cell = [self sOtherCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)sImageCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectImgCell" forIndexPath:indexPath];
    
    UIImageView * selectImgView = (UIImageView *)[cell.contentView viewWithTag:1001];
    selectImgView.image = self.idImage;
    
    UIImageView * camView = (UIImageView *)[cell.contentView viewWithTag:1002];
    if (self.idImage) {
        camView.hidden = YES;
    }
    else {
        camView.hidden = NO;
    }
    
    UIButton *selectBtn = (UIButton *)[cell.contentView viewWithTag:1003];
    
    [[[selectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [self pickImage];
    }];
    
    
    
    return cell;
}

- (UITableViewCell *)sOtherCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectOtherCell" forIndexPath:indexPath];
    UIImageView *backgroundView = (UIImageView *)[cell.contentView viewWithTag:1001];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PickInsCompaniesVC *vc = [UIStoryboard vcWithId:@"PickInsCompaniesVC" inStoryboard:@"Car"];
    [vc setPickedBlock:^(NSString *name) {
        
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pickImage {
    
    [self.view endEditing:YES];
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
            [MobClick event:@"rp124_6"];
            return ;
        }
        
        //拍照
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0)
        {
            [MobClick event:@"rp124_4"];
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
            [MobClick event:@"rp124_5"];
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //图片压缩
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *croppedImage = [image compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    self.idImage = croppedImage;
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
