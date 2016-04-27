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
#import "EstimatedPriceVC.h"
#import "MutualInsHomeVC.h"
#import "GetCooperationIdlicenseInfoOp.h"
#import "MutualInsStore.h"
#import "MutualInsGrouponVC.h"

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
//先保险公司
@property (nonatomic, copy)NSString * insCompany;
//上一年度保险公司
@property (nonatomic, copy)NSString * lastYearInsCompany;
// 保险到期日
@property (nonatomic, strong)NSDate *insuranceExpirationDate;
// 服务器下发的最小保险到期日
@property (nonatomic, strong)NSDate *minInsuranceExpirationDate;
@property (nonatomic, strong)DatePickerVC *datePicker;
@property (nonatomic, strong)PictureRecord * currentRecord;

@property (nonatomic,strong)PickInsCompaniesVC * pickInsCompanysVC;


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
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
}

- (void)setupNextBtn
{
    @weakify(self);
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe":@"shenhe0007"}];
        
        @strongify(self)
        if (self.idPictureRecord.isUploading || self.drivingLicensePictureRecord.isUploading)
        {
            [gToast showMistake:@"请等待图片上传成功"];
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
        if (!self.insCompany.length)
        {
            [gToast showMistake:@"请选择现保险公司"];
            return ;
        }
        if (!self.insuranceExpirationDate)
        {
            [gToast showMistake:@"请选择商业险到期日期"];
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
    headerLabel.textColor = kGrayTextColor;
    headerLabel.font = [UIFont systemFontOfSize:16];
    if (section == 0) {
        headerLabel.text = @"请上传车主身份证照片";
    }
    else if (section == 1) {
        headerLabel.text = @"请上传车辆行驶证照片";
    }
    else if (section == 2) {
        headerLabel.text = @"请选择保险公司";
    }
    else{
        headerLabel.text = @"请选择商业险到期日期";
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
        CGFloat height = 666.0 / 1024 * width;
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
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        if (indexPath.section == 0)
        {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe":@"shenhe0002"}];
        }
        else
        {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe":@"shenhe0003"}];
        }
        self.currentRecord = indexPath.section == 0 ? self.idPictureRecord : self.drivingLicensePictureRecord;
        [self pickImageWithIndex:indexPath];
    }
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe":@"shenhe0004"}];
        }
        else
        {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe":@"shenhe0005"}];
        }
        @weakify(self)
        [self.pickInsCompanysVC setPickedBlock:^(NSString *name) {
            
            @strongify(self)
            if (indexPath.row == 0)
                self.insCompany = name;
            else
                self.lastYearInsCompany = name;
        }];
        
        [self.navigationController pushViewController:self.pickInsCompanysVC animated:YES];
    }
    if (indexPath.section == 3)
    {
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe":@"shenhe0006"}];
        if (self.minInsuranceExpirationDate)
        {
            NSDate *nextDat = [NSDate dateWithTimeInterval:24*60*60 sinceDate:self.minInsuranceExpirationDate];//后一天
            self.datePicker.minimumDate = nextDat;
        }
        NSDate *selectedDate = self.insuranceExpirationDate ? self.insuranceExpirationDate : nil;
        
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
    
    record.customArray = [NSMutableArray arrayWithArray:@[selectImgView,camView]];
    
    [selectImgView removeTagGesture];
    UIImageView *maskView = selectImgView.customObject;
    selectImgView.hidden = !record.image;
    selectImgView.image = record.image;
    camView.hidden = record.image;
    
    
    if (!maskView) {
        maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm_watermark"]];
        [selectImgView insertSubview:maskView atIndex:0];
        selectImgView.customObject = maskView;
    }
    @weakify(self)
    @weakify(selectImgView)
    [[[selectImgView.reuploadButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntilForCell:cell] subscribeNext:^(id x) {
        
        @strongify(selectImgView)
        @strongify(self)
        self.currentRecord = indexPath.section == 0 ? self.idPictureRecord : self.drivingLicensePictureRecord;
        [self actionUpload:self.currentRecord withImageView:selectImgView];
    }];
    
    [[[selectImgView.pickImageButton rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntilForCell:cell] subscribeNext:^(id x) {
        
        @strongify(self)
        self.currentRecord = indexPath.section == 0 ? self.idPictureRecord : self.drivingLicensePictureRecord;
        [self pickImageWithIndex:indexPath];
    }];
    
    
    
    
    [[RACObserve(record, image) takeUntilForCell:cell] subscribeNext:^(UIImage * img) {
        
        selectImgView.hidden = !img;
        selectImgView.image = img;
        camView.hidden = img;
    }];
    
    
    [[RACObserve(record, url) takeUntilForCell:cell] subscribeNext:^(NSString * url) {
        
        @strongify(self)
        if (url.length && !record.image)
        {
            camView.hidden = YES;
            [selectImgView setImageByUrl:record.url withType:ImageURLTypeMedium defImageObj:[self defImage] errorImageObj:[self errorImage]];
        }
    }];
    
    
    /// 图片适应
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
                lb.textColor = str.length ? kDarkTextColor : kGrayTextColor;
            }];
        }
        else
        {
            [[RACObserve(self, lastYearInsCompany) takeUntilForCell:cell] subscribeNext:^(NSString * str) {
                
                lb.text = str.length ? str : @"请选择上一年保险公司";
                lb.textColor = str.length ? kDarkTextColor : kGrayTextColor;
            }];
        }
    }
    else
    {
        [[RACObserve(self, insuranceExpirationDate) takeUntilForCell:cell] subscribeNext:^(NSDate * date) {
            
            lb.text = date ? [date dateFormatForYYMMdd] : @"请选择商业险到期日期";
            lb.textColor = date ? kDarkTextColor : kGrayTextColor;
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
    op.req_firstinscomp = self.insCompany ?: @"";
    op.req_secinscomp = self.lastYearInsCompany ?: @"";
    op.req_insenddate = [self.insuranceExpirationDate dateFormatForD10] ?: @"";
    op.req_memberid = self.memberId;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"信息上传中"];
    }] subscribeNext:^(id x) {
        
        [gToast dismiss];
        
        EstimatedPriceVC * vc = [UIStoryboard vcWithId:@"EstimatedPriceVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = self.memberId;
        vc.groupId = self.groupId;
        vc.groupName = self.groupName;
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
        self.minInsuranceExpirationDate = rop.rsp_mininsenddate;
    } error:^(NSError *error) {
        
        @weakify(self)
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:[NSString stringWithFormat:@"%@ \n点击再试一次",error.domain] tapBlock:^{
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
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    }];
}

- (void)actionUpload:(PictureRecord *)record withImageView:(HKImageView *)imageView {
    
    record.isUploading = YES;
    [[imageView rac_setUploadingImage:self.currentRecord.image withImageType:UploadFileTypeMutualIns]
     subscribeNext:^(UploadFileOp *op) {
         
         record.url = [op.rsp_urlArray safetyObjectAtIndex:0];
         record.picID = [op.rsp_idArray safetyObjectAtIndex:0];
         
         record.isUploading = NO;
         imageView.tapGesture.enabled = NO;
     } error:^(NSError *error) {
         
     }];
}

-(void)back
{
    //刷新团列表信息
    [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] sendAndIgnoreError];
    [[[MutualInsStore fetchExistsStore] reloadDetailGroupByMemberID:self.memberId andGroupID:self.groupId] sendAndIgnoreError];
    
    MutualInsGrouponVC *grouponvc;
    MutualInsHomeVC *homevc;
    NSInteger homevcIndex = NSNotFound;
    for (NSInteger i=0; i<self.navigationController.viewControllers.count; i++) {
        UIViewController *vc = self.navigationController.viewControllers[i];
        if ([vc isKindOfClass:[MutualInsGrouponVC class]]) {
            grouponvc = (MutualInsGrouponVC *)vc;
            break;
        }
        if ([vc isKindOfClass:[MutualInsHomeVC class]]) {
            homevc = (MutualInsHomeVC *)vc;
            homevcIndex = i;
        }
    }
    if (grouponvc) {
        [self.navigationController popToViewController:grouponvc animated:YES];
        return;
    }
    //创建团详情视图
    grouponvc  = [mutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponVC"];
    HKMutualGroup * group = [[HKMutualGroup alloc] init];
    group.groupId = self.groupId;
    group.groupName = self.groupName;
    group.memberId = self.memberId;
    grouponvc.group = group;
    
    NSMutableArray *vcs = [NSMutableArray array];
    if (homevcIndex != NSNotFound) {
        NSArray *subvcs = [self.navigationController.viewControllers subarrayToIndex:homevcIndex+1];
        [vcs addObjectsFromArray:subvcs];
    }
    else {
        //创建团root视图
        homevc = [UIStoryboard vcWithId:@"MutualInsHomeVC" inStoryboard:@"MutualInsJoin"];
        [vcs addObject:self.navigationController.viewControllers[0]];
        [vcs addObject:homevc];
    }
    [vcs addObject:grouponvc];
    [vcs addObject:self];
    self.navigationController.viewControllers = vcs;
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)actionBack:(id)sender {
    
    [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe":@"shenhe0001"}];
    
    if (self.idPictureRecord.image || self.drivingLicensePictureRecord.image || self.insCompany.length || self.insuranceExpirationDate || self.lastYearInsCompany.length || self.idPictureRecord.url.length || self.drivingLicensePictureRecord.url.length)
    {
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
            [self back];
        }];
        HKImageAlertVC *alertVC = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您有未保存的信息，是否在当前页面继续编辑？" ActionItems:@[cancel,confirm]];
        [alertVC show];
    }
    else
    {
        [self back];
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

- (PickInsCompaniesVC *)pickInsCompanysVC
{
    if (!_pickInsCompanysVC)
        _pickInsCompanysVC = [UIStoryboard vcWithId:@"PickInsCompaniesVC" inStoryboard:@"Car"];
    return _pickInsCompanysVC;
    
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
