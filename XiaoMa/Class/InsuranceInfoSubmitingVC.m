//
//  InsuranceInfoSubmitingVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceInfoSubmitingVC.h"
#import "DrivingLicenseHistoryView.h"
#import "HKImageView.h"
#import "JGActionSheet.h"
#import "InsuranceResultVC.h"
#import "UIView+Shake.h"
#import "UpdateInsuranceCalculateOp.h"
#import "InsuranceAppointmentOp.h"
#import "InsuranceChooseViewController.h"

@interface InsuranceInfoSubmitingVC ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, DrivingLicenseHistoryViewDelegate>
{
    UIImage *_defImage;
    UIImage *_errorImage;
}
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomContentView1;
@property (weak, nonatomic) IBOutlet UIView *bottomContentView2;
@property (weak, nonatomic) IBOutlet UIView *defContainerView;
@property (nonatomic, strong) IBOutlet DrivingLicenseHistoryView *historyView;
@property (nonatomic, strong) UITextField *idcardField;
@property (nonatomic, strong) UITextField *inviteField;
@property (nonatomic, strong) PictureRecord *currentRecord;
@property (nonatomic, strong) HKImageView *imageView;
@property (nonatomic, assign) BOOL isUploading;
@property (nonatomic, strong) NSMutableArray *datasource;

@end

@implementation InsuranceInfoSubmitingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bottomContentView1.hidden = self.submitModel != InsuranceInfoSubmitForDirectSell;
    self.bottomContentView2.hidden = self.submitModel != InsuranceInfoSubmitForEnquiry;
    [self reloadData];
    [self setupDrivingLicenseHistoryView];
//    [self reloadDrivingLicenseHistoryWithCell:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp126"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp126"];
}

- (void)setupDrivingLicenseHistoryView
{
    self.historyView.delegate = self;
    [[[RACObserve(self.historyView, recordList) distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSArray *records) {
        if (records.count > 0) {
            if (self.datasource.count < 5) {
                NSArray *item = @[@"PreviewCell",@106];
                [self.datasource safetyInsertObject:item atIndex:2];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }
        else {
            if (self.datasource.count >= 5) {
                [self.datasource safetyRemoveObjectAtIndex:2];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }
    }];
    
    [[self.historyView rac_reloadDataWithSelectedRecord:self.currentRecord] subscribeNext:^(id x) {
        
    }];
}

- (void)reloadData
{
    NSArray *data = @[@[self.submitModel == InsuranceInfoSubmitForDirectSell ? @"HeaderCell" : @"HeaderCell2", @64],
                      @[@"CardCell",@82],
                      @[@"ImageCell",@(ceil((CGRectGetWidth(self.tableView.frame)-28)*414/594.0))],
                      @[@"InviteCell",@75]];
    self.datasource = [NSMutableArray arrayWithArray:data];
    [self.tableView reloadData];
}

#pragma mark - Action
- (BOOL)checkInfomation
{
    if (self.idcardField.text.length < 18) {
        [self.idcardField.superview shake];
        return NO;
    }
    else if (self.currentRecord.url.length == 0) {
        [self.imageView.superview.superview shake];
        return NO;
    }
    return YES;
}

- (IBAction)actionNext:(id)sender
{
    [MobClick event:@"rp126-10"];
    if ([self checkInfomation]) {
        InsuranceChooseViewController *vc = [UIStoryboard vcWithId:@"InsuranceChooseViewController" inStoryboard:@"Insurance"];
        vc.idcard = self.idcardField.text;
        vc.inviteCode = self.inviteField.text;
        vc.currentRecord = self.currentRecord;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)actionEnquire:(id)sender
{
    [MobClick event:@"rp126-4"];
    if ([self checkInfomation]) {
        UpdateInsuranceCalculateOp *op = [[UpdateInsuranceCalculateOp alloc] init];
        op.req_cid = self.calculatorOp.rsp_calculatorID;
        op.req_idcard = self.idcardField.text;
        op.req_driverpic = self.currentRecord.url;
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"正在提交..."];
        }] subscribeNext:^(id x) {

            @strongify(self);
            [gToast dismiss];
            InsuranceResultVC *vc = [UIStoryboard vcWithId:@"InsuranceResultVC" inStoryboard:@"Insurance"];
            vc.resultTitle = @"恭喜，上传成功！";
            vc.resultContent = @"精准询价：工作人员将于1个工作日内为您精准报价！";
            [self.navigationController pushViewController:vc animated:YES];
        } error:^(NSError *error) {
            
            [gToast showError:error.domain];
        }];
    }
}
- (IBAction)actionBuy:(id)sender {
    [MobClick event:@"rp126-7"];
    if ([self checkInfomation]) {
        InsuranceAppointmentOp *op = [[InsuranceAppointmentOp alloc] init];
        op.req_purchaseprice = self.calculatorOp.req_purchaseprice;
        op.req_idcard = self.idcardField.text;
        op.req_driverpic = self.currentRecord.url;
        op.req_inslist = self.insuranceList;
        op.req_invitecode = self.inviteField.text;
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"正在预约..."];
        }] subscribeNext:^(id x) {

            @strongify(self);
            [gToast dismiss];
            InsuranceResultVC *vc = [UIStoryboard vcWithId:@"InsuranceResultVC" inStoryboard:@"Insurance"];
            [self.navigationController pushViewController:vc animated:YES];
        } error:^(NSError *error) {
            
            [gToast showError:error.domain];
        }];
    }
}

- (void)actionUpload:(id)sender {
    [MobClick event:@"rp126-8"];
    @weakify(self);
    [[[self.imageView rac_setUploadingImage:self.currentRecord.image withImageType:UploadFileTypeDrivingLicense]
      initially:^{
          
          @strongify(self);
          self.isUploading = YES;
      }] subscribeNext:^(UploadFileOp *op) {
          
          @strongify(self);
          self.currentRecord.url = [op.rsp_urlArray safetyObjectAtIndex:0];
          self.currentRecord.picID = [op.rsp_idArray safetyObjectAtIndex:0];
          [self reloadDrivingLicenseHistoryWithCell:nil];
          self.isUploading = NO;
      } error:^(NSError *error) {
          
          @strongify(self);
          self.isUploading = NO;
      }];
}

- (void)actionRepickImage:(id)sender {
    [MobClick event:@"rp126-8"];
    [self _pickImage];
}

- (IBAction)actionPickImage:(id)sender {
    [MobClick event:@"rp126-3"];
    [self _pickImage];
}

- (void)_pickImage {

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

#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [MobClick event:@"rp126-1"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger length = range.location + [string length] - range.length;
    //身份证
    if ([textField isEqual:self.idcardField]) {
        if (length > 18) {
            return NO;
        }
    }
    if ([textField isEqual:self.inviteField]) {
        if (length > 50) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *item = [self.datasource safetyObjectAtIndex:indexPath.row];
    return [(NSNumber *)[item safetyObjectAtIndex:1] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSArray *item = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString *identifier = [item safetyObjectAtIndex:0];
    if ([@"HeaderCell" equalByCaseInsensitive:identifier] || [@"HeaderCell2" equalByCaseInsensitive:identifier]) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    }
//    @[@"CardCell",@82],
//    @[@"PreviewCell",@106],
//    @[@"ImageCell",@(ceil((CGRectGetWidth(self.tableView.frame)-28)*414/594.0))],
//    @[@"InviteCell",@75]]
    else if ([@"CardCell" equalByCaseInsensitive:identifier]) {
        cell = [self idCardCellAtIndexPath:indexPath identifier:identifier];
    }
    else if ([@"PreviewCell" equalByCaseInsensitive:identifier]) {
        cell = [self previewCellAtIndexPath:indexPath identifier:identifier];
    }
    else if ([@"ImageCell" equalByCaseInsensitive:identifier]) {
        return [self imageCellAtIndexPath:indexPath identifier:identifier];
    }
    else if ([@"InviteCell" equalByCaseInsensitive:identifier]) {
        return [self inviteCellAtIndexPath:indexPath identifier:identifier];
    }
    return cell;
}

#pragma mark - Cell
- (UITableViewCell *)idCardCellAtIndexPath:(NSIndexPath *)indexPath identifier:identifier
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (!self.idcardField) {
        self.idcardField = (UITextField *)[cell viewWithTag:10002];
        self.idcardField.delegate = self;
    }
    return cell;
}

- (UITableViewCell *)previewCellAtIndexPath:(NSIndexPath *)indexPath identifier:identifier
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    UIView *container = [cell.contentView viewWithTag:10003];
    if (![self.historyView.superview isEqual:container]) {
        [self.historyView removeFromSuperview];
        [container addSubview:self.historyView];
        [self.historyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(container);
        }];
    }
    return cell;
}

- (void)reloadDrivingLicenseHistoryWithCell:(UITableViewCell *)cell
{
    if (!cell) {
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    }
    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cell.contentView viewWithTag:10002];
    [[[self.historyView rac_reloadDataWithSelectedRecord:self.currentRecord] initially:^{
        [activity startAnimating];
    }] subscribeNext:^(id x) {
        [activity stopAnimating];
    } error:^(NSError *error) {
        [activity stopAnimating];
    }];

}

- (UITableViewCell *)imageCellAtIndexPath:(NSIndexPath *)indexPath identifier:identifier
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    UIView *imgContainerView = [cell.contentView viewWithTag:1000];
    [imgContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    HKImageView *imageView = (HKImageView *)[cell.contentView viewWithTag:1001];
    UIImageView *maskView = imageView.customObject;
    UIView *defContainerView = [cell.contentView viewWithTag:2000];

    if (!self.imageView) {
        self.imageView = imageView;
        [imageView.tapGesture addTarget:self action:@selector(actionPickImage:)];
        [imageView.reuploadButton addTarget:self action:@selector(actionUpload:) forControlEvents:UIControlEventTouchUpInside];
        [imageView.pickImageButton addTarget:self action:@selector(actionRepickImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!maskView) {
        maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm_watermark"]];
        [imageView insertSubview:maskView atIndex:0];
        imageView.customObject = maskView;
    }

    [[RACObserve(self, currentRecord) takeUntilForCell:cell] subscribeNext:^(PictureRecord *record) {
        
        if (record) {
            imgContainerView.hidden = NO;
            defContainerView.hidden = YES;
            if (record.image) {
                [imageView setImage:record.image];
            }
            else {
                [imageView setImageByUrl:record.url withType:ImageURLTypeMedium defImageObj:[self defImage] errorImageObj:[self errorImage]];
            }
        }
        else {
            imgContainerView.hidden = YES;
            defContainerView.hidden = NO;
        }
    }];
    
    @weakify(self);
    [[RACObserve(self.imageView, image) takeUntilForCell:cell] subscribeNext:^(UIImage *img) {
        
        @strongify(self);
        if (!img || [[self defImage] isEqual:img] || [[self errorImage] isEqual:img]) {
            maskView.hidden = YES;
            return ;
        }
        if (img.size.width > 0 && img.size.height > 0) {
            CGFloat imgRatio = img.size.height / img.size.width;
            CGFloat boundsRatio = (imgContainerView.frame.size.height-10) / (imgContainerView.frame.size.width-10);
            CGFloat maskRatio = 666.0/1024;
            CGSize size = CGSizeZero;
            //高度优先
            if (imgRatio > boundsRatio) {
                size.width = ceil((imgContainerView.frame.size.height-10) / imgRatio);
                size.height = ceil(size.width * maskRatio);
            }
            else {
                size.width = imgContainerView.frame.size.width-10;
                size.height = ceil(size.width*maskRatio);
            }

            [maskView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(size);
                make.center.equalTo(imageView);
            }];
        }
        maskView.hidden = NO;
    }];
    return cell;
}

- (UITableViewCell *)inviteCellAtIndexPath:(NSIndexPath *)indexPath identifier:identifier
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:10002];
    if (!self.inviteField) {
        self.inviteField = textField;
    }
    return cell;
}
#pragma mark - Getter
- (UIImage *)defImage
{
    if (!_defImage) {
        _defImage = [UIImage imageNamed:@"cm_defpic"];
    }
    return _defImage;
}

- (UIImage *)errorImage
{
    if (!_errorImage) {
        _errorImage = [UIImage imageNamed:@"cm_defpic_fail"];
    }
    return _errorImage;
}

#pragma mark - DrivingLicenseHistoryViewDelegate
- (BOOL)shouldSelectedAtIndex:(NSInteger)index
{
    if (self.isUploading) {
        [self.imageView.superview.superview shake];
        return NO;
    }
    return YES;
}

- (void)didSelectedAtIndex:(NSInteger)index
{
    self.currentRecord = [self.historyView currentSelectedRecord];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //图片压缩
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *croppedImage = [image compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    PictureRecord *record = [[PictureRecord alloc] init];
    record.image = croppedImage;
    self.currentRecord = record;
    self.historyView.selectedRecordIndex = NSNotFound;
    [self actionUpload:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
