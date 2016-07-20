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
#import "UpdateCooperationIdlicenseInfoV2Op.h"
#import "GetCooperationIdlicenseInfoOp.h"
#import "MutualInsStore.h"
#import "ProvinceChooseView.h"
#import "OETextField.h"
#import "UIView+RoundedCorner.h"
#import "CollectionChooseVC.h"
#import "MutualInsPicUpdateResultVC.h"
#import "MyCarStore.h"

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
//现保险公司
@property (nonatomic, copy)NSString * insCompany;
//上一年度保险公司
@property (nonatomic, copy)NSString * lastYearInsCompany;

@property (nonatomic, strong)PictureRecord * currentRecord;

/// 是否代买交强险
@property (nonatomic)BOOL isNeedBuyStrongInsurance;

@property (nonatomic,strong)PickInsCompaniesVC * pickInsCompanysVC;

@property (nonatomic,strong)CKList * datasource;

@property (nonatomic,strong)NSString * lisenceNumberArea;
@property (nonatomic,strong)NSString * lisenceNumberSuffix;


@end

@implementation MutualInsPicUpdateVC

- (void)dealloc
{
    DebugLog(@"MutualInsPicUpdateVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNeedBuyStrongInsurance = YES;
    
    [self setupUI];
    [self setupDatasource];
    [self.tableView reloadData];
    
    if (self.memberId)
    {
        // 有memeber说明是重新上传的
        [self requesLastIdLicenseInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup UI
- (void)setupUI
{
    [self setupNavigationBar];
    [self setupNextBtn];
    self.tableView.backgroundColor = kBackgroundColor;

}

- (void)setupNextBtn
{
    @weakify(self);
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"wanshanziliao" attributes:@{@"wanshanziliao":@"wanshanziliao7"}];
        
        @strongify(self)
        if (!self.curCar.licencenumber)
        {
            if (![self verifiedLicenseNumberFrom:[self.lisenceNumberArea append:self.lisenceNumberSuffix]])
            {
                [gToast showMistake:@"请输入正确的车牌号码"];
                return ;
            }
        }
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

        
        
        if (!self.isNeedBuyStrongInsurance)
        {
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"我要买" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                @strongify(self)
                self.isNeedBuyStrongInsurance = YES;
                
                [self requestUpdateImageInfo];
            }];
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"不要买" color:kGrayTextColor clickBlock:^(id alertVC) {
                @strongify(self)
                self.isNeedBuyStrongInsurance = NO;
                
                [self requestUpdateImageInfo];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您确认无需本平台为您代理购买交强险/车船税？" ActionItems:@[confirm,cancel]];
            [alert show];
            return;
        }
        
        [self requestUpdateImageInfo];
        
    }];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)setupDatasource
{
    CKDict * cell0 = [self setupLinsenceCell];
    
    CKDict * cell1_0 = [self setupTitleCell:@"请上传车主身份证照片"];
    CKDict * cell1_1 = [self setupImageCellWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    CKDict * cell1_2 = [self setupTitleCell:@"请上传车车辆行驶证照片"];
    CKDict * cell1_3 = [self setupImageCellWithIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]];
//
    CKDict * cell2_0 = [self setupTitleCell:@"请选择保险公司"];
    CKDict * cell2_1 = [self setupInsCompanyCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    CKDict * cell2_2 = [self setupInsCompanyCellWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
//
    CKDict * cell3 = [self setupCheckCell];
    
    self.datasource = $($(cell0),$(cell1_0,cell1_1,cell1_2,cell1_3),$(cell2_0,cell2_1,cell2_2),$(cell3));
}

- (CKDict *)setupLinsenceCell
{
    CKDict * cell0 = [CKDict dictWith:@{kCKCellID:@"PlateNumberCell"}];
    cell0[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 45;
    });
    
    @weakify(self);
    cell0[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
        label.text = @"车牌号码";
        ProvinceChooseView *chooseV = (ProvinceChooseView *)[cell.contentView viewWithTag:1002];
        [chooseV setCornerRadius:5 withBorderColor:kDefTintColor borderWidth:0.5];
        
        OETextField *field = (OETextField *)[cell.contentView viewWithTag:1003];
        [field setNormalInputAccessoryViewWithDataArr:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];
        field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        


        cell.contentView.userInteractionEnabled  = !self.curCar;
        
        if (self.curCar.licencenumber)
        {
            self.lisenceNumberArea = [self.curCar.licencenumber safteySubstringToIndexIndex:1];
            self.lisenceNumberSuffix = [self.curCar.licencenumber safteySubstringFromIndex:1];
        }

        @weakify(self);
        [[[chooseV rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             
             @strongify(self);
             CollectionChooseVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"CollectionChooseVC"];
             HKNavigationController *nav = [[HKNavigationController alloc] initWithRootViewController:vc];
             vc.datasource = gAppMgr.getProvinceArray;
             [vc setSelectAction:^(NSDictionary * d) {
                 
                 NSString * key = [d.allKeys safetyObjectAtIndex:0];
                 self.lisenceNumberArea = key;
                 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
             }];
             [self presentViewController:nav animated:YES completion:nil];
         }];
        
        
        field.textLimit = 6;
        [field setTextDidChangedBlock:^(CKLimitTextField *field) {
            @strongify(self);
            NSString *newtext = [field.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            field.text = [newtext uppercaseString];
            self.lisenceNumberSuffix = field.text;
        }];
        
        self.lisenceNumberArea = self.lisenceNumberArea.length ? self.lisenceNumberArea : [self getCurrentProvince];
        chooseV.displayLb.text = self.lisenceNumberArea.length ? self.lisenceNumberArea : [self getCurrentProvince];
        field.text = self.lisenceNumberSuffix.length ? self.lisenceNumberSuffix : @"";
    });

    return cell0;
}

- (CKDict *)setupImageCellWithIndexPath:(NSIndexPath *)indexPath
{
    CKDict * imageCell = [CKDict dictWith:@{kCKCellID:@"SelectImgCell"}];
    imageCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        // 图片
        CGFloat width = gAppMgr.deviceInfo.screenSize.width - 60;
        CGFloat height = 330.0 / 620.0 * width;
        return height;
    });
    
    @weakify(self)
    imageCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        
        @strongify(self)
        PictureRecord * record = indexPath.row == 1 ? self.idPictureRecord : self.drivingLicensePictureRecord;
        
        HKImageView * selectImgView = (HKImageView *)[cell.contentView viewWithTag:1001];
     
           UIImageView * camView = (UIImageView *)[cell.contentView viewWithTag:1002];
        
        record.customArray = [NSMutableArray arrayWithArray:@[selectImgView,camView]];
        [selectImgView removeTagGesture];
        UIImageView *maskView = selectImgView.customObject;
        selectImgView.hidden = !record.image;
        selectImgView.image = record.image;
        camView.hidden = (BOOL)record.image;
        
        
        if (!maskView) {
            maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm_watermark"]];
            [selectImgView insertSubview:maskView atIndex:0];
            selectImgView.customObject = maskView;
        }
        @weakify(self)
        [[[selectImgView.reuploadButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            self.currentRecord = indexPath.row == 1 ? self.idPictureRecord : self.drivingLicensePictureRecord;
            [self actionUpload:self.currentRecord withImageView:selectImgView];
        }];
        
        [[[selectImgView.pickImageButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            self.currentRecord = indexPath.row == 1 ? self.idPictureRecord : self.drivingLicensePictureRecord;
            [self pickImageWithIndex:indexPath];
        }];
        
        
        
        
        [[RACObserve(record, image) takeUntilForCell:cell] subscribeNext:^(UIImage * img) {
            
            selectImgView.hidden = !img;
            selectImgView.image = img;
            camView.hidden = (BOOL)img;
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
                CGFloat maskRatio = 330.0/620;
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
    });
    imageCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        if (indexPath.row == 1)
        {
            [MobClick event:@"wanshanziliao" attributes:@{@"wanshanziliao":@"wanshanziliao2"}];
        }
        else
        {
            [MobClick event:@"wanshanziliao" attributes:@{@"wanshanziliao":@"wanshanziliao3"}];
        }
        self.currentRecord = indexPath.row == 1 ? self.idPictureRecord : self.drivingLicensePictureRecord;
        [self pickImageWithIndex:indexPath];
    });
    
    return imageCell;
}

- (CKDict *)setupInsCompanyCellWithIndexPath:(NSIndexPath *)indexPath
{
    CKDict * insCompanyCell = [CKDict dictWith:@{kCKCellID:@"SelectOtherCell"}];
    insCompanyCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {

        return 50;
    });
    
    @weakify(self)
    insCompanyCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        UILabel * lb = (UILabel *)[cell.contentView viewWithTag:20101];
        if (indexPath.row == 1)
        {
            [[RACObserve(self, insCompany) takeUntilForCell:cell] subscribeNext:^(NSString * str) {
                
                lb.text = str.length ? str : @"当前投保的保险公司(必填)";
                lb.textColor = str.length ? kDarkTextColor : kGrayTextColor;
            }];
        }
        else
        {
            [[RACObserve(self, lastYearInsCompany) takeUntilForCell:cell] subscribeNext:^(NSString * str) {
                
                lb.text = str.length ? str : @"上年度投保的保险公司(选填)";
                lb.textColor = str.length ? kDarkTextColor : kGrayTextColor;
            }];
        }
    });
    
    insCompanyCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        if (indexPath.row == 1)
        {
            [MobClick event:@"wanshanziliao" attributes:@{@"wanshanziliao":@"wanshanziliao4"}];
        }
        else
        {
            [MobClick event:@"wanshanziliao" attributes:@{@"wanshanziliao":@"wanshanziliao5"}];
        }
        @strongify(self)
        @weakify(self)
        [self.pickInsCompanysVC setPickedBlock:^(NSString *name) {
            
            @strongify(self)
            if (indexPath.row == 1)
            {
                self.insCompany = name;
            }
            else
            {
                self.lastYearInsCompany = name;
            }
        }];
        
        [self.navigationController pushViewController:self.pickInsCompanysVC animated:YES];
    });
    
    return insCompanyCell;
}

- (CKDict *)setupCheckCell
{
    CKDict * checkCell = [CKDict dictWith:@{kCKCellID:@"CheckCell"}];
    checkCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 56;
    });
    
    @weakify(self)
    checkCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        UIButton * checkBtn = [cell viewWithTag:101];
        [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             
             [MobClick event:@"wanshanziliao" attributes:@{@"wanshanziliao":@"wanshanziliao6"}];
             self.isNeedBuyStrongInsurance = !self.isNeedBuyStrongInsurance;
         }];
        
        
        [[RACObserve(self, isNeedBuyStrongInsurance) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * x) {
            
            BOOL flag = [x boolValue];
            UIImage * image = flag ? [UIImage imageNamed:@"checkbox_selected"] : [UIImage imageNamed:@"checkbox_normal_301"];
            [checkBtn setImage:image forState:UIControlStateNormal];
        }];
    });
    
    return checkCell;
}

- (CKDict *)setupTitleCell:(NSString *)title
{
    CKDict * titleCell = [CKDict dictWith:@{kCKCellID:@"TitleCell"}];
    titleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 34;
    });
    
    titleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel * lb = [cell viewWithTag:101];
        lb.text = title;
    });
    
    return titleCell;
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 16)];
        view.backgroundColor = kBackgroundColor;
        UIView * view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
        view2.backgroundColor = [UIColor whiteColor];
        [view addSubview:view2];
        return view;
    }
    else
    {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
        view.backgroundColor = kBackgroundColor;
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 16;
    }
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block) {
        return block(data,indexPath);
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block) {
        block(data, cell, indexPath);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block) {
        block(data, indexPath);
    }
}

#pragma mark - Request
- (void)requestUpdateImageInfo
{
    UpdateCooperationIdlicenseInfoV2Op * op = [[UpdateCooperationIdlicenseInfoV2Op alloc] init];
    op.req_idurl = self.idPictureRecord.url;
    op.req_licenseurl = self.drivingLicensePictureRecord.url;
    op.req_firstinscomp = self.insCompany ?: @"";
    op.req_secinscomp = self.lastYearInsCompany ?: @"";
    op.req_memberid = self.memberId;
    op.req_isbuyfroceins = self.isNeedBuyStrongInsurance;
    op.req_groupid = self.groupId;
    if (self.curCar.licencenumber)
    {
        op.req_licensenumber = self.curCar.licencenumber;
    }
    else
    {
        op.req_licensenumber = [self.lisenceNumberArea append:self.lisenceNumberSuffix];;
    }
    op.req_carid = self.curCar.carId;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"信息上传中"];
    }] subscribeNext:^(UpdateCooperationIdlicenseInfoV2Op * op) {
        
        [gToast dismiss];
        
        [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] send];
        [[[MyCarStore fetchExistsStore] getAllCars] send];
        
        MutualInsPicUpdateResultVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateResultVC" inStoryboard:@"MutualInsJoin"];
        vc.tipsDict = op.couponDict;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)requesLastIdLicenseInfo
{
    GetCooperationIdlicenseInfoOp * op = [[GetCooperationIdlicenseInfoOp alloc] init];
    op.req_memberId = self.memberId;
    
    @weakify(self)
    [[[op rac_postRequest] initially:^{
        
        @strongify(self)
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetCooperationIdlicenseInfoOp * rop) {
        
        @strongify(self)
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
        [self.view hideDefaultEmptyView];
        [self.view stopActivityAnimation];
        self.idPictureRecord.url = rop.rsp_idnourl;
        self.drivingLicensePictureRecord.url = rop.rsp_licenseurl;
        self.insCompany = rop.rsp_lstinscomp;
        self.lastYearInsCompany = rop.rsp_secinscomp;
    } error:^(NSError *error) {
        
        @strongify(self)
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        [self.view stopActivityAnimation];
        @weakify(self)
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
    UIImage *img = indexPath.row == 1 ?  [UIImage imageNamed:@"ins_pic1"] : [UIImage imageNamed:@"ins_pic2"];
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
         
         record.isUploading = NO;
     }];
}

- (void)back
{
    if (self.groupId)
    {
        if (self.router.userInfo[kOriginRoute])
        {
            [self.router.navigationController popToRouter:self.router.userInfo[kOriginRoute] animated:YES];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
         [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)actionBack:(id)sender {
    
    [MobClick event:@"wanshanziliao" attributes:@{@"wanshanziliao":@"wanshanziliao1"}];
    
    if (self.idPictureRecord.image || self.drivingLicensePictureRecord.image || self.insCompany.length  || self.lastYearInsCompany.length || self.idPictureRecord.url.length || self.drivingLicensePictureRecord.url.length)
    {
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"继续" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"放弃" color:kGrayTextColor clickBlock:^(id alertVC) {
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

- (NSString *)getCurrentProvince
{
    for (NSDictionary * d in gAppMgr.getProvinceArray)
    {
        NSString * key = [d.allKeys safetyObjectAtIndex:0];
        NSString * value = [d objectForKey:key];
        NSString * v = [value stringByReplacingOccurrencesOfString:@"(" withString:@""];
        v = [v stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSString *province = gMapHelper.addrComponent.province;
        if (province && [province hasSubstring:v])
        {
            return  key;
        }
    }
    return @"浙";
}

- (NSString *)verifiedLicenseNumberFrom:(NSString *)licenseNumber
{
    if (!licenseNumber)
        return nil;
    
    NSString *pattern = @"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵黔粤粵青藏川宁琼使][a-z][a-z0-9]{5}[警港澳领学]{0,1}$";
    //    NSString *pattern = @"^[a-z][a-z0-9]{5}[警港澳领学]{0,1}$";
    NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *rst = [regexp firstMatchInString:licenseNumber options:0 range:NSMakeRange(0, [licenseNumber length])];
    if (!rst) {
        return nil;
    }
    return [licenseNumber uppercaseString];
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
