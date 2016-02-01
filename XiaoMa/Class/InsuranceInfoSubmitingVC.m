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
#import "UIView+Shake.h"
#import "InsuranceAppointmentV3Op.h"
#import "HKCellData.h"
#import "CKLine.h"
#import "InsuranceStore.h"
#import "NSString+RectSize.h"
#import "HKSubscriptInputField.h"

#import "InsCoverageSelectVC.h"

@interface InsuranceInfoSubmitingVC ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DrivingLicenseHistoryViewDelegate>
{
    UIImage *_defImage;
    UIImage *_errorImage;
}
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *defContainerView;
@property (nonatomic, strong) IBOutlet DrivingLicenseHistoryView *historyView;
@property (nonatomic, strong) PictureRecord *currentRecord;
@property (nonatomic, strong) HKImageView *imageView;
@property (nonatomic, assign) BOOL isUploading;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) InsuranceStore *insStore;

@end

@implementation InsuranceInfoSubmitingVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"InsuranceInfoSubmitingVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.insStore = [InsuranceStore fetchOrCreateStore];
    [self reloadData];
    [self setupDrivingLicenseHistoryView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Datasource
- (void)reloadData
{
    HKCellData *headerCell = [HKCellData dataWithCellID:@"Header" tag:nil];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 5;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"上传资料，达达帮您填写！\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17], NSForegroundColorAttributeName:HEXCOLOR(@"#20ab2a"), NSParagraphStyleAttributeName: ps}];
    if (self.insStore.xmddHelpTip.length > 0) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:self.insStore.xmddHelpTip attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor darkTextColor], NSParagraphStyleAttributeName: [NSParagraphStyle defaultParagraphStyle]}]];
    }
    headerCell.object = text;
    [headerCell setHeightBlock:^CGFloat(UITableView *tableView) {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width-73-14,10000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        return MAX(ceil(rect.size.height+26), 78);
    }];
    
    HKCellData *cardCell = [HKCellData dataWithCellID:@"Card" tag:nil];
    [cardCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 84;
    }];
    HKCellData *imageCell = [HKCellData dataWithCellID:@"Image" tag:nil];
    [imageCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return ceil((CGRectGetWidth(self.tableView.frame)-28)*414/594.0);
    }];
    
    self.datasource = [NSMutableArray arrayWithObjects:headerCell,cardCell,imageCell, nil];
    [self.tableView reloadData];
}

- (void)setupDrivingLicenseHistoryView
{
    self.historyView.delegate = self;
    [[[RACObserve(self.historyView, recordList) distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSArray *records) {
         if (records.count > 0) {
             if (self.datasource.count < 4) {
                 HKCellData *historyCell = [HKCellData dataWithCellID:@"History" tag:nil];
                 [historyCell setHeightBlock:^CGFloat(UITableView *tableView) {
                     return 106;
                 }];
                 [self.datasource safetyInsertObject:historyCell atIndex:2];
                 [self.tableView beginUpdates];
                 [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                 [self.tableView endUpdates];
             }
         }
         else {
             if (self.datasource.count >= 4) {
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


#pragma mark - Action
- (BOOL)checkInfomation
{
    if ([[(HKCellData *)self.datasource[1] object] length] < 18) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        HKSubscriptInputField *field = [cell viewWithTag:10002];
        [field shake];
        return NO;
    }
    else if (self.currentRecord.url.length == 0) {
        [self.imageView.superview.superview shake];
        return NO;
    }
    return YES;
}

- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1002-1"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionNext:(id)sender
{
    [MobClick event:@"rp1002-7"];
    if ([self checkInfomation]) {
        InsuranceAppointmentV3Op *op = [InsuranceAppointmentV3Op operation];
        op.req_idcard = [(HKCellData *)self.datasource[1] object];
        op.req_driverpic = self.currentRecord.url;
        op.req_licenseno = self.insModel.simpleCar.licenseno;
        
        InsCoverageSelectVC *vc = [UIStoryboard vcWithId:@"InsCoverageSelectVC" inStoryboard:@"Insurance"];
        vc.selectMode = InsuranceSelectModeAppointment;
        vc.insModel = self.insModel;
        vc.appointmentOp = op;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionUpload:(id)sender {
    [MobClick event:@"rp1002-8"];
    @weakify(self);
    [[[self.imageView rac_setUploadingImage:self.currentRecord.image withImageType:UploadFileTypeDaDaHelp]
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
    [MobClick event:@"rp1002-8"];
    [self _pickImage];
}

- (IBAction)actionPickImage:(id)sender {
    [MobClick event:@"rp1002-6"];
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

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource objectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Header" tag:nil]) {
        [self resetHeaderCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Card" tag:nil]){
        [self resetIdCardCell:cell forData:data];
    }
    else if ([data equalByCellID:@"History" tag:nil]) {
        [self resetHistoryCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Image" tag:nil]) {
        [self resetImageCell:cell forData:data];
    }
    return cell;
}

#pragma mark - Cell
- (void)resetHeaderCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *textL = [cell viewWithTag:1002];
    CKLine *line1 = [cell viewWithTag:10001];
    CKLine *line2 = [cell viewWithTag:10002];
    
    line1.lineAlignment = CKLineAlignmentHorizontalTop;
    line2.lineAlignment = CKLineAlignmentHorizontalBottom;
    textL.attributedText = data.object;
}
- (void)resetIdCardCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    HKSubscriptInputField *field = [cell viewWithTag:10002];
    
    field.inputField.placeholder = @"请输入身份证号码";
    field.inputField.textLimit = 18;
    field.inputField.keyboardType = UIKeyboardTypeASCIICapable;
    [field.inputField setDidBeginEditingBlock:^(CKLimitTextField *field) {
        [MobClick event:@"rp1002-2"];
    }];
    [field.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {

        data.object = field.text;
    }];
}

- (void)resetHistoryCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIView *container = [cell.contentView viewWithTag:10003];
    if (![self.historyView.superview isEqual:container]) {
        [self.historyView removeFromSuperview];
        [container addSubview:self.historyView];
        [self.historyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(container);
        }];
    }
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

- (void)resetImageCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
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
