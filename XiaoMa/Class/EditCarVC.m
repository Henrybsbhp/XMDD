//
//  EditCarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EditCarVC.h"
#import "XiaoMa.h"
#import "AddCarOp.h"
#import "UpdateCarOp.h"
#import "DeleteCarOp.h"
#import "DatePickerVC.h"
#import "UIView+Shake.h"
#import "PickAutomobileBrandVC.h"
#import "PickerAutoModelVC.h"
#import "CollectionChooseVC.h"
#import "ProvinceChooseView.h"
#import "PickInsCompaniesVC.h"
#import "MyCarStore.h"
#import "HKCellData.h"
#import "CKLimitTextField.h"
#import "HKTableViewCell.h"
#import "AreaTablePickerVC.h"
#import "CarIDCodeCheckModel.h"
#import "OETextField.h"
#import "UIView+RoundedCorner.h"

@interface EditCarVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HKMyCar *curCar;
@property (nonatomic, assign) BOOL isEditingModel;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) DatePickerVC *datePicker;
@property (nonatomic, assign) BOOL isDrivingLicenseNeedSave;
@property (nonatomic, assign) BOOL isKeyboardAppear;

@end

@implementation EditCarVC


- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"EditCarVC dealloc");
}

- (void)awakeFromNib {
    self.model = [MyCarListVModel new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDatePicker];
    [self setupNavigationBar];
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.editing = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


//设置日期选择控件（主要是为了事先加载，优化性能）
- (void)setupDatePicker
{
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(actionSave:)];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(actionCancel:)];
    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.rightBarButtonItem = right;
}

- (void)setupTableView
{
    if (self.originCar) {
        _curCar = [self.originCar copy];
        _isEditingModel = YES;
    }
    else {
        _curCar = [[HKMyCar alloc] init];
        _curCar.licenceArea  = [self getCurrentProvince];
        _curCar.isDefault = YES;
        _isEditingModel = NO;
    }
    
    [self reloadDatasource];
}

- (void)reloadDatasource
{
    NSMutableArray *datasource = [NSMutableArray array];
    //section 0
    [datasource addObject:[self dataListForSection0]];
    
    //section 1
    [datasource addObject:[self dataListForSection1]];
    
    //section 2
    [datasource addObject:[self dataListForSection2]];
    
    //section 3
    HKCellData *cell3_0 = [HKCellData dataWithCellID:@"Switch" tag:nil];
    cell3_0.customInfo[@"title"] = @"设为默认车辆";
    cell3_0.object = @(self.curCar.isDefault);
    [datasource addObject:@[cell3_0]];
    
    //section 4
    if (!(self.model.allowAutoChangeSelectedCar || !_isEditingModel || !(self.curCar.editMask & HKCarEditableDelete))) {
        HKCellData *cell4_0 = [HKCellData dataWithCellID:@"Delete" tag:nil];
        [datasource addObject:@[cell4_0]];
    }

    self.datasource = datasource;
    [self.tableView reloadData];
}

- (NSArray *)dataListForSection0
{
    HKCellData *cell1_0 = [HKCellData dataWithCellID:@"Header" tag:nil];
    cell1_0.object = @"基本爱车信息（必填）";
    [cell1_0 setHeightBlock:^CGFloat(UITableView *tableView) {
        return 50;
    }];
    return @[cell1_0];
}

- (NSArray *)dataListForSection1
{
    //section 1
    @weakify(self);
    HKCellData *cell1_0 = [HKCellData dataWithCellID:@"Title" tag:nil];
    cell1_0.object = @"基本爱车信息（必填）";
    
    HKCellData *cell1_1 = [HKCellData dataWithCellID:@"PlateNumber" tag:nil];
    cell1_1.customInfo[@"title"] = @"车牌号码";
    cell1_1.object = RACObserve(self.curCar, licencenumber);
    cell1_1.customInfo[@"inspector"] = [^BOOL(NSIndexPath *indexPath) {
        @strongify(self);
        if (self.curCar.licenceSuffix.length == 0) {
            [self showErrorAtIndexPath:indexPath errorMsg:@"车牌号码不能为空"];
            return NO;
        }
        //之前验证时入参为licencenumber，为空，切验证结果应为：nil
        else if (![MyCarStore verifiedLicenseNumberFrom:[self.curCar wholeLicenseNumber]]) {
            [self showErrorAtIndexPath:indexPath errorMsg:@"请输入正确的车牌号码"];
            return NO;
        }
        return YES;
    } copy];
    
    HKCellData *cell1_2 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell1_2.customInfo[@"title"] = @"购车时间";
    cell1_2.customInfo[@"placehold"] = @"请选择购车时间";
    cell1_2.customInfo[@"inspector"] = [^BOOL(NSIndexPath *indexPath) {
        @strongify(self);
        if (!self.curCar.purchasedate) {
            [self showErrorAtIndexPath:indexPath errorMsg:@"购车时间不能为空"];
            return NO;
        }
        return YES;
    } copy];
    cell1_2.object = [RACObserve(self.curCar, purchasedate) map:^id(NSDate *date) {
        return [date dateFormatForYYMMdd];
    }];
    [cell1_2 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp312_3"];
        [self.view endEditing:YES];
        self.datePicker.maximumDate = [NSDate date];
        NSDate *selectedDate = self.curCar.purchasedate ? self.curCar.purchasedate : [NSDate date];
        
        [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:selectedDate]
         subscribeNext:^(NSDate *date) {
             @strongify(self);
             self.curCar.purchasedate = date;
         }];
    }];
    
    HKCellData *cell1_3 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell1_3.customInfo[@"title"] = @"品牌车系";
    cell1_3.customInfo[@"placehold"] = @"请选择品牌车系";
    cell1_3.object = [[RACObserve(self.curCar, brand) merge:RACObserve(self.curCar, seriesModel.seriesname)] map:^id(id value) {
        if (self.curCar.brand && self.curCar.seriesModel.seriesname) {
            return [NSString stringWithFormat:@"%@ %@", self.curCar.brand, self.curCar.seriesModel.seriesname];
        }
        return nil;
    }];
    cell1_3.customInfo[@"inspector"] = [^BOOL(NSIndexPath *indexPath) {
        @strongify(self);
        if (self.curCar.brand.length == 0 || self.curCar.seriesModel.seriesname.length == 0) {
            [self showErrorAtIndexPath:indexPath errorMsg:@"品牌车系不能为空"];
            return NO;
        }
        return YES;
    } copy];
    [cell1_3 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp312_4"];
        [self.view endEditing:YES];
        PickAutomobileBrandVC *vc = [UIStoryboard vcWithId:@"PickerAutomobileBrandVC" inStoryboard:@"Car"];
        vc.originVC = self;
        [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel *series, AutoDetailModel *model) {
            self.curCar.brandid = brand.brandid;
            self.curCar.brand = brand.brandname;
            self.curCar.brandLogo = brand.brandLogo;
            self.curCar.seriesModel = series;
            self.curCar.detailModel = model;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    HKCellData *cell1_4 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell1_4.customInfo[@"title"] = @"具体车型";
    cell1_4.customInfo[@"placehold"] = @"请选择具体车型";
    cell1_4.object = RACObserve(self.curCar, detailModel.modelname);
    cell1_4.customInfo[@"inspector"] = [^BOOL(NSIndexPath *indexPath) {
        @strongify(self);
        if (self.curCar.detailModel.modelname.length == 0) {
            [self showErrorAtIndexPath:indexPath errorMsg:@"具体车型不能为空"];
            return NO;
        }
        return YES;
    } copy];
    [cell1_4 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp312_5"];
        [self.view endEditing:YES];
        if ([self.curCar.seriesModel.seriesid integerValue] != 0) {
            PickerAutoModelVC *vc = [UIStoryboard vcWithId:@"PickerAutoModelVC" inStoryboard:@"Car"];
            vc.series = self.curCar.seriesModel;
            vc.originVC = self;
            [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel *series, AutoDetailModel * model) {
                self.curCar.detailModel = model;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            PickAutomobileBrandVC *vc = [UIStoryboard vcWithId:@"PickerAutomobileBrandVC" inStoryboard:@"Car"];
            vc.originVC = self;
            [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel *series, AutoDetailModel *model) {
                self.curCar.brandid = brand.brandid;
                self.curCar.brand = brand.brandname;
                self.curCar.brandLogo = brand.brandLogo;
                self.curCar.seriesModel = series;
                self.curCar.detailModel = model;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    return @[cell1_0,cell1_1,cell1_2,cell1_3,cell1_4];
}

- (NSArray *)dataListForSection2
{
    @weakify(self);
    //section 2
    HKCellData *cell2_0 = [HKCellData dataWithCellID:@"Title" tag:nil];
    cell2_0.object = @"更多爱车信息（选填）";
    
    HKCellData *cell2_1 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell2_1.customInfo[@"title"] = @"行驶城市";
    cell2_1.customInfo[@"placehold"] = @"请选择行驶城市";
    cell2_1.object = RACObserve(self.curCar, cityName);
    [cell2_1 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        
        [MobClick event:@"rp312_18"];
        
        @strongify(self);
        [self.view endEditing:YES];
        
        AreaTablePickerVC * vc = [AreaTablePickerVC initPickerAreaVCWithType:PickerVCTypeProvinceAndCity fromVC:self];
        
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * disctrictModel) {
            
            NSString * cityName = [NSString stringWithFormat:@"%@",cityModel.infoName];
            self.curCar.cityName = cityName;
            self.curCar.provinceName = provinceModel.infoName;
            self.curCar.provinceId = @(provinceModel.infoId);
            self.curCar.cityId = @(cityModel.infoId);
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    
    HKCellData *cell2_2 = [HKCellData dataWithCellID:@"Field" tag:nil];
    cell2_2.customInfo[@"title"] = @"车架号码";
    cell2_2.customInfo[@"placehold"] = @"请填写车架号码";
    cell2_2.customInfo[@"howDisplay"] = @(YES);
    cell2_2.customInfo[@"block"] = [^(OETextField *field, RACSignal *stopSig) {
        @strongify(self);
        
        [field setNormalInputAccessoryViewWithDataArr:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];
        
        field.text = self.curCar.classno;
        
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            /**
             *  车架号码点击事件
             */
            [MobClick event:@"rp312_19"];
        }];
        
        [field setTextDidChangedBlock:^(CKLimitTextField *rFiled) {
            @strongify(self);
            
            NSString *temp = [rFiled.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            rFiled.text = [temp uppercaseString];
            self.curCar.classno = rFiled.text;
        }];
    } copy];
    cell2_2.customInfo[@"inspector"] = [^BOOL(NSIndexPath *indexPath) {
        @strongify(self);
        
        if (self.curCar.classno.length && ![CarIDCodeCheckModel carIDCheckWithCodeStr:self.curCar.classno]) {
            [self showErrorAtIndexPath:indexPath errorMsg:@"请输入正确的车架号码"];
            return NO;
        }
        return YES;
    } copy];
    
    cell2_2.customInfo[@"howAction"] = [^(void){
        
        [self showPicture:@"ins_eg_pic1"];
    } copy];

    HKCellData *cell2_3 = [HKCellData dataWithCellID:@"Field" tag:nil];
    cell2_3.customInfo[@"title"] = @"发动机号";
    cell2_3.customInfo[@"placehold"] = @"请填写发动机号";
    cell2_3.customInfo[@"howDisplay"] = @(YES);
    cell2_3.customInfo[@"block"] = [^(OETextField *field, RACSignal *stopSig) {
        @strongify(self);
        
        [field setNormalInputAccessoryViewWithDataArr:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];
        field.text = self.curCar.engineno;
        
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            /**
             *  发动机号
             */
            [MobClick event:@"rp312_20"];
        }];
        
        [field setTextDidChangedBlock:^(CKLimitTextField *rFiled) {
            @strongify(self);
            
            NSString *temp = [rFiled.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            rFiled.text = [temp uppercaseString];
            self.curCar.engineno = rFiled.text;
        }];

    } copy];
    cell2_3.customInfo[@"howAction"] = [^(void){
        
        [self showPicture:@"ins_eg_pic3"];
    } copy];
    
    HKCellData *cell2_4 = [HKCellData dataWithCellID:@"Field" tag:nil];
    cell2_4.customInfo[@"title"] = @"整车价格";
    cell2_4.customInfo[@"suffix"] = @"万";
    cell2_4.customInfo[@"block"] = [^(CKLimitTextField *field, RACSignal *stopSig) {
        @strongify(self);
        field.text = [NSString stringWithFormat:@"%.2f", self.curCar.price];
        field.keyboardType = UIKeyboardTypeDecimalPad;
        field.clearsOnBeginEditing = YES;
        field.textLimit = 12;
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"rp312_6"];
        }];
        
        [field setTextDidChangedBlock:^(CKLimitTextField *rFiled) {
            @strongify(self);
            if (rFiled.text.length > 0) {
                self.curCar.price = [rFiled.text floatValue];
            }
        }];
        
        [field setDidEndEditingBlock:^(CKLimitTextField *field) {
            @strongify(self);
            field.text = [NSString stringWithFormat:@"%.2f", self.curCar.price];
        }];
    } copy];
    
    HKCellData *cell2_5 = [HKCellData dataWithCellID:@"Field" tag:nil];
    cell2_5.customInfo[@"title"] = @"行驶里程";
    cell2_5.customInfo[@"suffix"] = @"万公里";
    cell2_5.customInfo[@"block"] = [^(CKLimitTextField *field, RACSignal *stopSig) {
        @strongify(self);
        field.text = [NSString stringWithFormat:@"%@", [NSString formatForPrice:self.curCar.odo / 10000.00]];
        field.keyboardType = UIKeyboardTypeDecimalPad;
        field.clearsOnBeginEditing = YES;
        field.textLimit = 12;
//        field.regexpPattern = @"[1-9]\\d*|^0(?=$|0+$)";
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"rp312_7"];
        }];
        
        [field setTextDidChangedBlock:^(CKLimitTextField *rFiled) {
            @strongify(self);
            if (rFiled.text.length > 0) {
                self.curCar.odo = [rFiled.text floatValue] * 10000;
            }
        }];
        
        [field setDidEndEditingBlock:^(CKLimitTextField *field) {
            @strongify(self);
            field.text = [NSString stringWithFormat:@"%.2f", self.curCar.odo / 10000.00];
        }];
    } copy];
    
    HKCellData *cell2_6 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell2_6.customInfo[@"title"] = @"年检到期日";
    cell2_6.customInfo[@"placehold"] = @"请选择年检到期时间";
    cell2_6.object = [RACObserve(self.curCar, insexipiredate) map:^id(NSDate *date) {
        return [date dateFormatForYYMMdd];
    }];
    [cell2_6 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp312_8"];
        [self.view endEditing:YES];
        self.datePicker.maximumDate = nil;
        NSDate *date = self.curCar.insexipiredate ? self.curCar.insexipiredate : [NSDate date];
        
        [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:date]
         subscribeNext:^(NSDate *date) {
             @strongify(self);
             self.curCar.insexipiredate = date;
         }];
    }];
    
    HKCellData *cell2_7 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell2_7.customInfo[@"title"] = @"保险公司";
    cell2_7.customInfo[@"placehold"] = @"请选择保险公司";
    cell2_7.object = RACObserve(self.curCar, inscomp);
    [cell2_7 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp312_9"];
        [self.view endEditing:YES];
        PickInsCompaniesVC *vc = [UIStoryboard vcWithId:@"PickInsCompaniesVC" inStoryboard:@"Car"];
        [vc setPickedBlock:^(NSString *name) {
            self.curCar.inscomp = name;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return @[cell2_0,cell2_1,cell2_2,cell2_3,cell2_4,cell2_5,cell2_6,cell2_7];
}

#pragma mark - Action
- (void)actionSave:(id)sender
{
    [MobClick event:@"rp312_12"];
    for (NSInteger section = 0; section < self.datasource.count; section++) {
        NSArray *group = self.datasource[section];
        for (NSInteger row = 0; row < group.count; row++) {
            HKCellData *data = group[row];
            BOOL (^inspector)(NSIndexPath *) = data.customInfo[@"inspector"];
            if (!inspector) {
                continue;
            }
            BOOL success = inspector([NSIndexPath indexPathForRow:row inSection:section]);
            if (!success) {
                return;
            }
        }
    }

    MyCarStore *store = [MyCarStore fetchOrCreateStore];
    CKEvent *evt = self.isEditingModel ? [store updateCar:self.curCar] : [store addCar:self.curCar];
    @weakify(self);
    [[[[evt sendAndIgnoreError] initially:^{
        
        [gToast showingWithText:@"正在保存..."];
    }] delay:0.01] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast showSuccess:@"保存成功!"];
        self.isDrivingLicenseNeedSave = NO;
        if (self.model.finishBlock) {
            self.model.finishBlock(self.curCar);
        }
        if (self.model.originVC) {
            [self.navigationController popToViewController:self.model.originVC animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)_saveFromSignal:(RACSignal *)signal
{
    
}

- (void)actionCancel:(id)sender
{
    [MobClick event:@"312_13"];
    
    if (self.isEditingModel && ![self.curCar isDifferentFromAnother:self.originCar]) {
        if (self.model.originVC) {
            [self.navigationController popToViewController:self.model.originVC animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    if (!self.isEditingModel && !self.isDrivingLicenseNeedSave) {
        if (self.model.originVC) {
            [self.navigationController popToViewController:self.model.originVC animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    if (self.isEditingModel) {
        [self.view endEditing:YES];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"算了" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
            [MobClick event:@"rp312_14"];
            CKAfter(0.1, ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            [alertVC dismiss];
        }];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"保存" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [MobClick event:@"rp312_15"];
            [self actionSave:nil];
            [alertVC dismiss];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"您未保存信息，是否现在保存？" ActionItems:@[cancel,confirm]];
        [alert show];
    }
    else {
        [self.view endEditing:YES];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"放弃添加" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
            [MobClick event:@"rp312_16"];
            CKAfter(0.1, ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            [alertVC dismiss];
        }];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"继续添加" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [MobClick event:@"rp312_17"];
            [alertVC dismiss];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"您未保存行驶证，需填写相关必填项并点击“保存”后方能添加爱车。" ActionItems:@[cancel,confirm]];
        [alert show];
    }
}

- (IBAction)actionDelete:(id)sender
{
    [MobClick event:@"rp312_11"];
    //添加模式,点击删除直接返回上一页
    if (!self.isEditingModel) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    MyCarStore *store = [MyCarStore fetchOrCreateStore];
    [[[[[store removeCar:self.curCar.carId] sendAndIgnoreError] initially:^{
        
        [gToast showingWithText:@"正在删除..."];
    }] delay:0.01] subscribeNext:^(id x) {
        
        [gToast showSuccess:@"删除成功!"];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
    
}

- (IBAction)actionUpload:(id)sender
{
    [MobClick event:@"rp312_1"];
    @weakify(self);
    [[self.model rac_uploadDrivingLicenseWithTargetVC:self initially:^{
        [gToast showingWithText:@"正在上传..."];
    }] subscribeNext:^(NSString *url) {
        @strongify(self);
        [gToast showSuccess:@"上传成功!"];
        self.curCar.licenceurl = url;
        self.curCar.status = 1;
        self.isDrivingLicenseNeedSave = YES;
        [self reloadDatasource];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource safetyObjectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Header" tag:nil]) {
        [self resetHeaderCell:cell withData:data];
    }
    else if ([data equalByCellID:@"Title" tag:nil]) {
        [self resetTitleCell:cell withData:data atIndexPath:indexPath];
    }
    else if ([data equalByCellID:@"PlateNumber" tag:nil]) {
        [self resetPlateNumberCell:cell withData:data atIndexPath:indexPath];
    }
    else if ([data equalByCellID:@"Selection" tag:nil]) {
        [self resetSelectionCell:cell withData:data];
    }
    else if ([data equalByCellID:@"Field" tag:nil]) {
        [self resetFieldCell:cell withData:data];
    }
    else if ([data equalByCellID:@"Switch" tag:nil]) {
        [self resetSwitchCell:cell withData:data];
    }
    if (data.dequeuedBlock) {
        data.dequeuedBlock(tableView, cell, indexPath);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.isKeyboardAppear)
    {
        HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
        if (data.selectedBlock) {
            data.selectedBlock(tableView, indexPath);
        }
    }
    
    [self.view endEditing:YES];
}

#pragma mark - Cell
- (void)resetHeaderCell:(UITableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *descL = (UILabel *)[cell.contentView viewWithTag:1002];
    UIButton *uploadBtn = (UIButton *)[cell.contentView viewWithTag:1003];
    descL.minimumScaleFactor = 0.6;
    descL.adjustsFontSizeToFitWidth = YES;
    [self.model setupUploadBtn:uploadBtn andDescLabel:descL forCar:self.curCar];
}

- (void)resetTitleCell:(UITableViewCell *)cell withData:(HKCellData *)data atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    label.text = data.object;
    
    HKTableViewCell *hkcell = (HKTableViewCell *)cell;
    [hkcell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 14, 0, 14)];
}

- (void)resetPlateNumberCell:(UITableViewCell *)cell withData:(HKCellData *)data atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    ProvinceChooseView *chooseV = (ProvinceChooseView *)[cell.contentView viewWithTag:1002];
    OETextField *field = (OETextField *)[cell.contentView viewWithTag:1003];
    [field setNormalInputAccessoryViewWithDataArr:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];

    cell.contentView.userInteractionEnabled  = self.curCar.editMask & HKCarEditableEdit;

    label.text = data.customInfo[@"title"];
    
    [chooseV setCornerRadius:5 withBorderColor:HEXCOLOR(@"#18D06A") borderWidth:0.5];
    chooseV.displayLb.text = self.curCar.licenceArea.length ? self.curCar.licenceArea : [self getCurrentProvince];
    @weakify(self);
    [[[chooseV rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {

        @strongify(self);
        CollectionChooseVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"CollectionChooseVC"];
        JTNavigationController *nav = [[JTNavigationController alloc] initWithRootViewController:vc];
        vc.datasource = gAppMgr.getProvinceArray;
        [vc setSelectAction:^(NSDictionary * d) {

            @strongify(self);
            NSString * key = [d.allKeys safetyObjectAtIndex:0];
            self.curCar.licenceArea = key;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    

    field.textLimit = 6;
    field.text = self.curCar.licenceSuffix;
    
    [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = nil;
    }];
    
    [field setDidEndEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = @"A12345";
    }];
    
    [field setTextDidChangedBlock:^(CKLimitTextField *field) {
        @strongify(self);
        NSString *newtext = [field.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        field.text = [newtext uppercaseString];
        self.curCar.licenceSuffix = field.text;
    }];
}

- (void)resetSelectionCell:(UITableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];

    label.text = data.customInfo[@"title"];
    field.placeholder = data.customInfo[@"placehold"];
    [[[data.object distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString *text) {
        field.text = text;
    }];
}

- (void)resetFieldCell:(UITableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    CKLimitTextField *field = (CKLimitTextField *)[cell.contentView viewWithTag:1002];
    UILabel *suffixL = (UILabel *)[cell.contentView viewWithTag:1003];
    UIButton * howBtn = (UIButton *)[cell searchViewWithTag:104];
    
    howBtn.hidden = ![data.customInfo[@"howDisplay"] integerValue];
    
    label.text = data.customInfo[@"title"];
    suffixL.text = data.customInfo[@"suffix"];
    field.rightViewMode = UITextFieldViewModeNever;
    void(^block)(CKLimitTextField *filed, RACSignal *stopSig) = data.customInfo[@"block"] ;
    if (block) {
        block(field, [cell rac_prepareForReuseSignal]);
    }
    
    typedef void(^MyBlock)(void);
    MyBlock howAction = data.customInfo[@"howAction"];
    [[[howBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        howAction();
    }];
    
}

- (void)resetSwitchCell:(UITableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    UISwitch *switchV = (UISwitch *)[cell.contentView viewWithTag:1002];
    
    label.text = data.customInfo[@"title"];
    switchV.on = [data.object boolValue];
    @weakify(self);
    [[switchV rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *sw) {
        @strongify(self);
        [MobClick event:@"rp312_10"];
        BOOL on = sw.on;
        self.curCar.isDefault = on;
    }];
}

#pragma mark - Utility
- (void)showErrorAtIndexPath:(NSIndexPath *)indexPath errorMsg:(NSString *)msg
{
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [gToast showError:msg];
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


- (void)showPicture:(NSString *)picname
{
    CGSize size = CGSizeMake(300, 200);
    UIViewController *vc = [[UIViewController alloc] init];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.cornerRadius = 0;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleFade;
    sheet.shouldDismissOnBackgroundViewTap = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    sheet.portraitTopInset = floor((self.view.frame.size.height - size.height) / 2);
    
    [sheet presentAnimated:YES completionHandler:nil];
    
    vc.view.backgroundColor = [UIColor clearColor];
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:vc.view.bounds];
    [vc.view addSubview:imgv];
    imgv.autoresizingMask = UIViewAutoresizingFlexibleAll;
    imgv.image = [UIImage imageNamed:picname];
}


#pragma mark 键盘隐藏的监听方法
- (void)keyboardWillShow:(NSNotification *)notify
{
    self.isKeyboardAppear = YES;
}

- (void)keyboardWillHide:(NSNotification *) notify
{
    self.isKeyboardAppear = NO;
}

@end
