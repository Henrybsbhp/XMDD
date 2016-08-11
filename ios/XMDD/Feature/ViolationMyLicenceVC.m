//
//  ViolationMyLicenceVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ViolationMyLicenceVC.h"
#import "HKImagePicker.h"
#import "PictureRecord.h"
#import "HKImageView.h"
#import "JGActionSheet.h"
#import "GetViolationCommissionCarinfoOp.h"
#import "UpdateViolationCommissionCarinfoOp.h"

@interface ViolationMyLicenceVC ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImagePickerController *pickerController;

@property (strong, nonatomic) CKList *dataSource;
@property (strong, nonatomic) PictureRecord *originRcd;
@property (strong, nonatomic) PictureRecord *duplicateRcd;
@property (strong, nonatomic) PictureRecord *currentRecord;

@property (strong, nonatomic) PictureRecord *failedOriginRcd;
@property (strong, nonatomic) PictureRecord *failedDuplicateRcd;
@property (strong, nonatomic) NSNumber *carID;

@end

@implementation ViolationMyLicenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getViolationCommissionCarinfo];
    [self setupDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    DDLogDebug(@"ViolationMyLicenceVC dealloc");
}

#pragma mark - Setup

-(void)setupDataSource
{
    self.dataSource = $(
                        [self noticeCellDataWithNotice:[NSString stringWithFormat:@"请上传车辆（%@）行驶证正本",self.carNum]],
                        [self photoCellDataWithSampleImg:[UIImage imageNamed:@"illegal_original"]],
                        [self noticeCellDataWithNotice:[NSString stringWithFormat:@"请上传车辆（%@）行驶证副本",self.carNum]],
                        [self photoCellDataWithSampleImg:[UIImage imageNamed:@"illegal_licenceReavel"]],
                        [self blankCellData],
                        [self btnCellData]
                        );
}

#pragma mark - Network

-(void)getfailedOriginImg
{
    if (self.failedOriginRcd.url.length != 0)
    {
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:self.failedOriginRcd.url] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            self.failedOriginRcd.image = image;
        }];
    }
}

-(void)getfailedDuplicateImg
{
    if (self.failedDuplicateRcd.url.length != 0)
    {
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:self.failedDuplicateRcd.url] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            self.failedDuplicateRcd.image = image;
        }];
    }
}

-(void)getViolationCommissionCarinfo
{
    @weakify(self)
    GetViolationCommissionCarinfoOp *op = [GetViolationCommissionCarinfoOp operation];
    
    op.req_usercarid = self.usercarID;
    
    [[[op rac_postRequest]initially:^{
        
        @strongify(self)
        
        self.tableView.hidden = YES;
        
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        
    }]subscribeNext:^(GetViolationCommissionCarinfoOp *op) {
        
        [self.view stopActivityAnimation];
        
        self.tableView.hidden = NO;
        
        self.failedOriginRcd.url = op.rsp_licenseurl;
        self.failedDuplicateRcd.url = op.rsp_licensecopyurl;
        self.carID = op.rsp_carid;
        [self.tableView reloadData];
        [self getfailedOriginImg];
        [self getfailedDuplicateImg];
        
        
    } error:^(NSError *error) {
        
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败。点击请重试" tapBlock:^{
            
            @strongify(self)
            
            [self getViolationCommissionCarinfo];
            
        }];
        
    }];
}

-(void)updateViolationCommissionCarinfo
{
    UpdateViolationCommissionCarinfoOp *op = [UpdateViolationCommissionCarinfoOp operation];
    
    op.req_carid = self.carID;
    op.req_licenseurl = self.originRcd.url;
    op.req_licensecopyurl = self.duplicateRcd.url;
    op.req_usercarid = self.usercarID;
    op.req_licencenumber = self.carNum;
    
    [[[op rac_postRequest]initially:^{
        
        [gToast showingWithText:@"上传资料中"];
        
    }]subscribeNext:^(id x) {
        
        [gToast showSuccess:@"资料上传成功"];
        
        if (self.commitSuccessBlock)
        {
            self.commitSuccessBlock();
        }
        
        [self.navigationController popViewControllerAnimated:YES];

    } error:^(NSError *error) {
        
        [gToast showMistake:@"资料上传失败，请点击重试"];
        
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID]];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block)
    {
        block(data, cell, indexPath);
    }
    return cell;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block)
    {
        block(data, indexPath);
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block)
    {
        return block(data,indexPath);
    }
    else
    {
        return 40;
    }
}

#pragma mark - Cell

-(CKDict *)noticeCellDataWithNotice:(NSString *)notice
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"NoticeCell"}];
    
    
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 38;
    });
    //cell准备重绘
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *label = [cell viewWithTag:100];
        
        label.text = notice;
        
    });
    
    return data;
}

-(CKDict *)photoCellDataWithSampleImg:(UIImage *)sampleImg
{
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"PhotoCell"}];
    
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 168;
    });
    //cell准备重绘
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        HKImageView *selectImgView = [cell viewWithTag:101];
        selectImgView.layer.masksToBounds = YES;
        selectImgView.layer.borderColor = HEXCOLOR(@"#E1E1E1").CGColor;
        selectImgView.layer.borderWidth = 1;
        
        UIView *cameraImg = [cell viewWithTag:102];
        cameraImg.layer.borderColor = HEXCOLOR(@"#E1E1E1").CGColor;
        cameraImg.layer.borderWidth = 1;
        
        UIImageView *sampleImgView = [cell viewWithTag:1000];
        sampleImgView.image = sampleImg;
        
        PictureRecord *record;
        record = indexPath.row == 1 ? self.originRcd : self.duplicateRcd;
        record.customArray = [NSMutableArray arrayWithArray:@[selectImgView,cameraImg]];
        
        [selectImgView removeTagGesture];
        selectImgView.hidden = !record.image;
        selectImgView.image = record.image;
        cameraImg.hidden = record.image;
        
        UIImageView *maskView = selectImgView.customObject;
        if (!maskView)
        {
            maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm_watermark"]];
            [selectImgView insertSubview:maskView atIndex:0];
            selectImgView.customObject = maskView;
        }
        
        [[RACObserve(self.failedOriginRcd, image)takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            @strongify(self)
            
            if (indexPath.row == 1 && self.failedOriginRcd.image)
            {
                selectImgView.hidden = NO;
                [selectImgView hideMaskView];
                selectImgView.image = self.failedOriginRcd.image;
                cameraImg.hidden = YES;
            }
            
        }];
        
        
        [[RACObserve(self.failedDuplicateRcd, image)takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            @strongify(self)
            
            if (indexPath.row == 3 && self.failedDuplicateRcd.image)
            {
                selectImgView.hidden = NO;
                [selectImgView hideMaskView];
                selectImgView.image = self.failedDuplicateRcd.image;
                cameraImg.hidden = YES;
            }
        }];
        
        [[[selectImgView.reuploadButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self)
            self.currentRecord = record;
            [self actionUpload:self.currentRecord withImageView:selectImgView];
        }];
        
        [[[selectImgView.pickImageButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self)
            self.currentRecord = record;
            [self pickImageWithIndex:indexPath];
        }];
        
        [[RACObserve(record, image) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(UIImage * img) {
            selectImgView.hidden = !img;
            selectImgView.image = img;
            cameraImg.hidden = img;
        }];
        
        
        [[RACObserve(record, url) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * url) {
            if (url.length && !record.image)
            {
                cameraImg.hidden = YES;
                [selectImgView hideMaskView];
                [selectImgView setImageByUrl:record.url withType:ImageURLTypeMedium defImageObj:[UIImage imageNamed:@"cm_defpic2"] errorImageObj:[UIImage imageNamed:@"cm_defpic_fail2"]];
            }
        }];
        
        [[RACObserve(selectImgView, image) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(UIImage *img) {
            if (record.url)
            {
                [selectImgView hideMaskView];
            }
            
            if (!img || [[UIImage imageNamed:@"cm_defpic2"] isEqual:img] || [[UIImage imageNamed:@"cm_defpic_fail2"] isEqual:img]) {
                maskView.hidden = YES;
                selectImgView.hidden = YES;
                cameraImg.hidden = NO;
                return ;
            }
            maskView.hidden = NO;
            selectImgView.hidden = NO;
            cameraImg.hidden = YES;
            
            if (img.size.width > 0 && img.size.height > 0) {
                CGFloat imgRatio = img.size.height / img.size.width;
                CGFloat boundsRatio = (selectImgView.frame.size.height-10) / (selectImgView.frame.size.width-10);
                CGFloat maskRatio = 666.0/1024;
                CGSize size = CGSizeZero;
                //高度优先
                if (imgRatio > boundsRatio)
                {
                    size.width = ceil((selectImgView.frame.size.height-10) / imgRatio);
                    size.height = ceil(size.width * maskRatio);
                }
                else
                {
                    size.width = selectImgView.frame.size.width-10;
                    size.height = ceil(size.width*maskRatio);
                }
                
                [maskView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(size);
                    make.center.equalTo(selectImgView);
                }];
            }
        }];
        
    });
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self)
        
        self.currentRecord = indexPath.row == 1 ? self.originRcd : self.duplicateRcd;
        
        [self pickImageWithIndex:indexPath];
    });
    return data;
}

-(CKDict *)btnCellData
{
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"BtnCell"}];
    
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 80;
        
    });
    //cell准备重绘
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
    
        UIButton *btn = [cell viewWithTag:100];
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            @strongify(self)
            
            if (self.originRcd.url == 0 || self.duplicateRcd.url.length == 0)
            {
                [gToast showMistake:@"请完善资料后上传"];
            }
            else if(self.originRcd.isUploading == YES || self.duplicateRcd.isUploading == YES)
            {
                [gToast showMistake:@"图片正在上传中，请稍等"];
            }
            else
            {
                [self updateViolationCommissionCarinfo];
            }
            
        }];
    });
    
    return data;
}

-(CKDict *)blankCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"BlankCell"}];
    
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 18;
    });
    
    return data;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
    //图片压缩
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *croppedImage = [image compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    self.currentRecord.image = croppedImage;
    if ([self.currentRecord isEqual:self.originRcd])
    {
        self.failedOriginRcd = nil;
    }
    else
    {
        self.failedDuplicateRcd = nil;
    }
    [self actionUpload:self.currentRecord withImageView:[self.currentRecord.customArray safetyObjectAtIndex:0]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utility

-(void)actionUpload:(PictureRecord *)record withImageView:(HKImageView *)imageView
{
    record.isUploading = YES;
    [[imageView rac_setUploadingImage:record.image withImageType:UploadFileTypeMutualIns]
     subscribeNext:^(UploadFileOp *op) {
         record.url = op.rsp_urlArray.firstObject;
         record.isUploading = NO;
         imageView.tapGesture.enabled = NO;
     } error:^(NSError *error) {
         
         record.isUploading = NO;
     }];
}


-(void)pickImageWithIndex:(NSIndexPath *)indexPath
{
    @weakify(self)
    [self.view endEditing:YES];
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"拍照",@"从相册选择"] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *section2 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"] buttonStyle:JGActionSheetButtonStyleCancel];
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
    UIImage *img;
    
    img = indexPath.row == 1 ? [UIImage imageNamed:@"ins_pic2"] : [UIImage imageNamed:@"ins_pic3"];
    
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
    label.text = @"所有上传资料均会加水印，小马保障您的隐私安全！";
    
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
                @strongify(self)
                self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                [self presentViewController:self.pickerController animated:YES completion:nil];
            }
            else
            {
                [gToast showMistake:@"该设备不支持拍照"];
            }
        }
        // 从相册中选取
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1)
        {
            self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.pickerController animated:YES completion:nil];
        }
    }];
}



#pragma mark - LazyLoad

-(CKList *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [CKList list];
    }
    return _dataSource;
}

-(UIImagePickerController *)pickerController
{
    if (!_pickerController)
    {
        _pickerController = [[UIImagePickerController alloc] init];
        _pickerController.delegate = self;
        _pickerController.customInfo[@"target"] = self;
        _pickerController.customObject = [RACSubject subject];
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        _pickerController.mediaTypes = mediaTypes;
    }
    return _pickerController;
}

-(PictureRecord *)originRcd
{
    if (!_originRcd)
    {
        _originRcd = [[PictureRecord alloc]init];
    }
    return _originRcd;
}

-(PictureRecord *)duplicateRcd
{
    if (!_duplicateRcd)
    {
        _duplicateRcd = [[PictureRecord alloc]init];
    }
    return _duplicateRcd;
}

-(PictureRecord *)failedDuplicateRcd
{
    if (!_failedDuplicateRcd)
    {
        _failedDuplicateRcd = [[PictureRecord alloc]init];
    }
    return _failedDuplicateRcd;
}

-(PictureRecord *)failedOriginRcd
{
    if (!_failedOriginRcd)
    {
        _failedOriginRcd = [[PictureRecord alloc]init];
    }
    return _failedOriginRcd;
}


-(PictureRecord *)currentRecord
{
    if (!_currentRecord)
    {
        _currentRecord = [[PictureRecord alloc]init];
    }
    return _currentRecord;
}

@end
