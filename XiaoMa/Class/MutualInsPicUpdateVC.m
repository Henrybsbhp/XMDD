//
//  EditInsInfoVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsPicUpdateVC.h"
#import "JGActionSheet.h"
#import "PickInsCompaniesVC.h"
#import "DatePickerVC.h"
#import "PictureRecord.h"
#import "HKImageView.h"
#import "UpdateCooperationIdlicenseInfoOp.h"
#import "MutualInsChooseViewController.h"
#import "MutualInsHomeVC.h"
#import "GetCooperationIdlicenseInfoOp.h"

@interface MutualInsPicUpdateVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImage *_defImage;
    UIImage *_errorImage;
}

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) PictureRecord * idPictureRecord;
@property (nonatomic, strong) PictureRecord * drivingLicensePictureRecord;
@property (nonatomic, copy)NSString * insCompany;
@property (nonatomic, copy)NSString * lastYearInsCompany;
@property (nonatomic, strong)NSDate *insuranceExpirationDate;
@property (nonatomic, strong)DatePickerVC *datePicker;
@property (nonatomic, strong)PictureRecord * currentRecord;


@end

@implementation MutualInsPicUpdateVC

- (void)dealloc
{
    DebugLog(@"MutualInsPicUpdateVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupNextBtn];
    [self setupDatePicker];
    
    [self requesLastIdLicenseInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup UI
- (void)setupDatePicker
{
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:[NSDate date]];
}

- (void)setupNextBtn
{
    @weakify(self);
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        if (self.idPictureRecord.isUploading || self.drivingLicensePictureRecord.isUploading)
        {
            [gToast showMistake:@"待图片上传成功"];
            return ;
        }
        if (!self.idPictureRecord.url.length)
        {
            [gToast showMistake:@"请上传身份证照片"];
            return ;
        }
        if (!self.drivingLicensePictureRecord.url.length)
        {
            [gToast showMistake:@"请上传行驶证照片"];
            return ;
        }
        
        [self requestUpdateImageInfo];
    }];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
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
    else if (section == 1) {
        headerLabel.text = @"请选择保险公司";
    }
    else{
        headerLabel.text = @"请选择保险到期日";
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
        
        PictureRecord * record = indexPath.section == 0 ? self.idPictureRecord : self.drivingLicensePictureRecord;
        CGFloat width = gAppMgr.deviceInfo.screenSize.width - 60;
        CGFloat height;
        if (record.image)
        {
            CGFloat imgRatio = record.image.size.height / record.image.size.width;
            height = imgRatio * width;
        }
        else
        {
            height = 666.0 / 1024 * width;
        }
        return height;
    }
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 || indexPath.section == 1) {
        cell = [self sImageCellAtIndexPath:indexPath];
    }
    else{
        cell = [self sOtherCellAtIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        PickInsCompaniesVC *vc = [UIStoryboard vcWithId:@"PickInsCompaniesVC" inStoryboard:@"Car"];
        [vc setPickedBlock:^(NSString *name) {
            
            if (indexPath.row == 0)
                self.insCompany = name;
            else
                self.lastYearInsCompany = name;
        }];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        self.datePicker.maximumDate = [NSDate date];
        NSDate *selectedDate = self.insuranceExpirationDate ? self.insuranceExpirationDate : [NSDate date];
        
        @weakify(self)
        [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:selectedDate]
         subscribeNext:^(NSDate *date) {
             @strongify(self);
             self.insuranceExpirationDate = date;
         }];
    }
}

#pragma mark - About Cell
- (UITableViewCell *)sImageCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectImgCell" forIndexPath:indexPath];
    
    PictureRecord * record = indexPath.section == 0 ? self.idPictureRecord : self.drivingLicensePictureRecord;
    
    HKImageView * selectImgView = (HKImageView *)[cell.contentView viewWithTag:1001];
    UIImageView * camView = (UIImageView *)[cell.contentView viewWithTag:1002];
    UIButton *selectBtn = (UIButton *)[cell.contentView viewWithTag:1003];
    
    record.customArray = [NSMutableArray arrayWithArray:@[selectImgView,camView]];
    
    UIImageView *maskView = selectImgView.customObject;
    selectImgView.hidden = !record.image;
    selectImgView.image = record.image;
    
    if (!maskView) {
        maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm_watermark"]];
        [selectImgView insertSubview:maskView atIndex:0];
        selectImgView.customObject = maskView;
    }
    
    camView.hidden = record.image;
    
    
    [[RACObserve(record, image) takeUntilForCell:cell] subscribeNext:^(UIImage * img) {
        
        selectImgView.hidden = !img;
        selectImgView.image = img;
        camView.hidden = img;
    }];
    
    @weakify(self)
    [[RACObserve(record, url) takeUntilForCell:cell] subscribeNext:^(NSString * url) {
        
        @strongify(self)
        if (url.length && !record.image)
        {
            camView.hidden = YES;
            [selectImgView setImageByUrl:record.url withType:ImageURLTypeMedium defImageObj:[self defImage] errorImageObj:[self errorImage]];
        }
    }];
    
    [[RACObserve(selectImgView, image) takeUntilForCell:cell] subscribeNext:^(UIImage *img) {
       
        @strongify(self)
        if (!img || [[self defImage] isEqual:img] || [[self errorImage] isEqual:img]) {
            maskView.hidden = YES;
            selectImgView.hidden = YES;
            camView.hidden = NO;
            return ;
        }
        maskView.hidden = NO;
        selectImgView.hidden = NO;
        camView.hidden = YES;
        
        if (img.size.width > 0 && img.size.height > 0) {
            CGFloat imgRatio = img.size.height / img.size.width;
            CGFloat boundsRatio = (selectImgView.frame.size.height-10) / (selectImgView.frame.size.width-10);
            CGFloat maskRatio = 666.0/1024;
            CGSize size = CGSizeZero;
            //高度优先
            if (imgRatio > boundsRatio) {
                size.width = ceil((selectImgView.frame.size.height-10) / imgRatio);
                size.height = ceil(size.width * maskRatio);
            }
            else {
                size.width = selectImgView.frame.size.width-10;
                size.height = ceil(size.width*maskRatio);
            }
            
            [maskView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(size);
                make.center.equalTo(selectImgView);
            }];
        }
    }];

    
    [[[selectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        self.currentRecord = indexPath.section == 0 ? self.idPictureRecord : self.drivingLicensePictureRecord;
        [self pickImageWithIndex:indexPath];
    }];
    
    return cell;
}

- (UITableViewCell *)sOtherCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectOtherCell" forIndexPath:indexPath];
    UILabel * lb = (UILabel *)[cell.contentView viewWithTag:20101];
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            [[RACObserve(self, insCompany) takeUntilForCell:cell] subscribeNext:^(NSString * str) {
                
                lb.text = str.length ? str : @"请选择现保险公司";
                lb.textColor = str.length ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#888888");
            }];
        }
        else
        {
            [[RACObserve(self, lastYearInsCompany) takeUntilForCell:cell] subscribeNext:^(NSString * str) {
                
                lb.text = str.length ? str : @"请选择现保险公司";
                lb.textColor = str.length ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#888888");
            }];
        }
    }
    else
    {
        [[RACObserve(self, insuranceExpirationDate) takeUntilForCell:cell] subscribeNext:^(NSDate * date) {
            
            lb.text = date ? [date dateFormatForYYMMdd] : @"请选择保险到期日";
            lb.textColor = date ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#888888");
        }];
    }
    
    return cell;
}
#pragma mark - Request
- (void)requestUpdateImageInfo
{
    UpdateCooperationIdlicenseInfoOp * op = [[UpdateCooperationIdlicenseInfoOp alloc] init];
    op.req_idurl = self.idPictureRecord.url;
    op.req_licenseurl = self.drivingLicensePictureRecord.url;
    op.req_firstinscomp = self.insCompany;
    op.req_secinscomp = self.lastYearInsCompany;
    op.req_insenddate = [self.insuranceExpirationDate dateFormatForD10];
    op.req_memberid = self.memberId;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"信息上传中"];
    }] subscribeNext:^(id x) {
        
        [gToast dismiss];
        MutualInsChooseViewController * vc = [UIStoryboard vcWithId:@"MutualInsChooseViewController" inStoryboard:@"MutualInsJoin"];
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)requesLastIdLicenseInfo
{
    GetCooperationIdlicenseInfoOp * op = [[GetCooperationIdlicenseInfoOp alloc] init];
    op.req_memberId = self.memberId;
    [[[op rac_postRequest] initially:^{
        
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetCooperationIdlicenseInfoOp * rop) {
        
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
        [self.view stopActivityAnimation];
        self.idPictureRecord.url = rop.rsp_idnourl;
        self.drivingLicensePictureRecord.url = rop.rsp_licenseurl;
        self.insCompany = rop.rsp_lstinscomp;
        self.lastYearInsCompany = rop.rsp_secinscomp;
        self.insuranceExpirationDate = rop.rsp_insenddate;
    } error:^(NSError *error) {
        
        @weakify(self)
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:[NSString stringWithFormat:@"%@ \n点击再试一次",error.domain] tapBlock:^{
            
            @strongify(self)
            [self requesLastIdLicenseInfo];
        }];
    }];
}
#pragma mark - Utility
- (void)pickImageWithIndex:(NSIndexPath *)indexPath {
    
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
    UIImage *img = indexPath.section ?  [UIImage imageNamed:@"ins_pic2"] : [UIImage imageNamed:@"ins_pic1"];
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
    
    [sheet setButtonPressedBlock:^(JGActionSheet *rsheet, NSIndexPath *sheetIndexPath) {
        
        [exampleView setHidden:YES animated:YES];
        [rsheet dismissAnimated:YES];
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

- (void)actionUpload:(PictureRecord *)record withImageView:(HKImageView *)imageView {
    
    record.isUploading = YES;
    [[imageView rac_setUploadingImage:self.currentRecord.image withImageType:UploadFileTypeDaDaHelp]
     subscribeNext:^(UploadFileOp *op) {
         
         record.url = [op.rsp_urlArray safetyObjectAtIndex:0];
         record.picID = [op.rsp_idArray safetyObjectAtIndex:0];
         
         record.isUploading = NO;
     }];
}



- (void)actionBack:(id)sender {
    
    for (UIViewController * vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:NSClassFromString(@"MutualInsHomeVC")] || [vc isKindOfClass:NSClassFromString(@"MutualInsHomeVC")])
        {
            [((MutualInsHomeVC *)vc) requestMyGourpInfo];
            [self.navigationController popToViewController:vc animated:YES];
            return ;
        }
        if ([vc isKindOfClass:NSClassFromString(@"MutualInsGrouponVC")])
        {
            [self.navigationController popToViewController:vc animated:YES];
            return ;
        }
    }

}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //图片压缩
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *croppedImage = [image compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    self.currentRecord.image = croppedImage;
    UIView * selectView = [self.currentRecord.customArray safetyObjectAtIndex:0];
    [self actionUpload:self.currentRecord withImageView:(HKImageView *)selectView];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy
- (PictureRecord *)idPictureRecord
{
    if (!_idPictureRecord)
        _idPictureRecord = [[PictureRecord alloc] init];
    return _idPictureRecord;
}

- (PictureRecord *)drivingLicensePictureRecord
{
    if (!_drivingLicensePictureRecord)
        _drivingLicensePictureRecord = [[PictureRecord alloc] init];
    return _drivingLicensePictureRecord;
}

#pragma mark - Getter
- (UIImage *)defImage
{
    if (!_defImage) {
        _defImage = [UIImage imageNamed:@"cm_defpic2"];
    }
    return _defImage;
}

- (UIImage *)errorImage
{
    if (!_errorImage) {
        _errorImage = [UIImage imageNamed:@"cm_defpic_fail2"];
    }
    return _errorImage;
}


@end
