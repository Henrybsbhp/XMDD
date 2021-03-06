//
//  EditCarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EditCarVC.h"
#import "Xmdd.h"
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
@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) DatePickerVC *datePicker;
@property (nonatomic, assign) BOOL isDrivingLicenseNeedSave;
@property (nonatomic, assign) BOOL isKeyboardAppear;

/// 是否展开
@property (nonatomic, assign) BOOL isMoreInfoExpand;

@end

@implementation EditCarVC


- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"EditCarVC dealloc");
}

- (void)awakeFromNib {
    [super awakeFromNib];
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
    self.datePicker.datePickerTitle = @"请选择购车时间";
}

- (void)setupNavigationBar
{
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(actionCancel:)];
    [left setTitleTextAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                                    } forState:UIControlStateNormal];

    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(actionSave:)];
    [right setTitleTextAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                                    } forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = left;
    [self.navigationItem setRightBarButtonItem:right animated:YES];//防抖动
}

- (void)setupTableView
{
    if (self.originCar) {
        _curCar = [self.originCar copy];
        _isEditingModel = YES;
        _isMoreInfoExpand = YES;
        [self reloadDatasource];
        [self.tableView reloadData];
    }
    else if (self.originCarId) {
        _isEditingModel = YES;
        _isMoreInfoExpand = YES;
        self.carStore = [MyCarStore fetchOrCreateStore];
        RACSignal *sig = [[self.carStore getAllCars] send];
        [self reloadDataWithSignal:sig carId:self.originCarId];
    }
    else {
        _curCar = [[HKMyCar alloc] init];
        _curCar.licenceArea  = [self getCurrentProvince];
        _curCar.isDefault = YES;
        _isEditingModel = NO;
        _isMoreInfoExpand = NO;
        [self reloadDatasource];
        [self.tableView reloadData];
    }
}

#pragma mark - Reload

- (void)reloadDataWithSignal:(RACSignal *)signal carId:(NSNumber *)carId
{
    @weakify(self);
    [[[signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        @strongify(self);
        self.tableView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
        _curCar = [self.carStore carByID:carId];
        self.originCar = [self.carStore carByID:carId];
        [self reloadDatasource];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        [self.view stopActivityAnimation];
        
        @weakify(self);
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络连接失败，点击重试" tapBlock:^{
            @strongify(self);
            RACSignal *sig = [[self.carStore getAllCars] send];
            [self reloadDataWithSignal:sig carId:carId];
        }];
    }];
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
    if (!(!_isEditingModel || !(self.curCar.editMask & HKCarEditableDelete))) {
        HKCellData *cell4_0 = [HKCellData dataWithCellID:@"Delete" tag:nil];
        [datasource addObject:@[cell4_0]];
    }
    
    self.datasource = datasource;
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
    
    
    HKCellData *cell1_3 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell1_3.customInfo[@"title"] = @"品牌车系";
    cell1_3.customInfo[@"placehold"] = @"请选择品牌车系";
    cell1_3.customInfo[@"disable"] = @(!(self.curCar.editMask & HKCarEditableEditCarModel));
    cell1_3.object = [[RACObserve(self.curCar, brand) merge:RACObserve(self.curCar, seriesModel.seriesname)] map:^id(id value) {
        @strongify(self);
        if (self.curCar.brand.length != 0 && self.curCar.seriesModel.seriesname) {
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
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"xuanzepinpai"}];
        [self.view endEditing:YES];
        if (!(self.curCar.editMask & HKCarEditableEditCarModel)) {
            return ;
        }
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
    cell1_4.customInfo[@"disable"] = @(!(self.curCar.editMask & HKCarEditableEditCarModel));
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
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"xuanzechexing"}];
        [self.view endEditing:YES];
        if (!(self.curCar.editMask & HKCarEditableEditCarModel)) {
            return ;
        }
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
    
    return @[cell1_0,cell1_1,cell1_3,cell1_4];
}

- (NSArray *)dataListForSection2
{
    @weakify(self);
    //section 2
    HKCellData *cell2_0 = [HKCellData dataWithCellID:@"Title" tag:nil];
    cell2_0.object = @"更多爱车信息（选填）";
    
    HKCellData *cell1_2 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell1_2.customInfo[@"title"] = @"购车时间";
    cell1_2.customInfo[@"placehold"] = @"请选择购车时间";
    cell1_2.object = [RACObserve(self.curCar, purchasedate) map:^id(NSDate *date) {
        return [date dateFormatForYYMMdd];
    }];
    [cell1_2 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"bianjigoucheshijian"}];
        [self.view endEditing:YES];
        self.datePicker.maximumDate = [NSDate date];
        NSDate *selectedDate = self.curCar.purchasedate ? self.curCar.purchasedate : [NSDate date];
        
        [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:selectedDate]
         subscribeNext:^(NSDate *date) {
             @strongify(self);
             self.curCar.purchasedate = date;
         }];
    }];
    
    HKCellData *cell2_1 = [HKCellData dataWithCellID:@"Selection" tag:nil];
    cell2_1.customInfo[@"title"] = @"行驶城市";
    cell2_1.customInfo[@"placehold"] = @"请选择行驶城市";
    cell2_1.object = RACObserve(self.curCar, cityName);
    [cell2_1 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"bianjixingshichengshi"}];
        @strongify(self);
        [self.view endEditing:YES];
        
        AreaTablePickerVC * vc = [AreaTablePickerVC initPickerAreaVCWithType:PickerVCTypeProvinceAndCity fromVC:self];
        
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * disctrictModel) {
            
            @strongify(self);
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
        
        [field setNormalInputAccessoryViewWithDataArr:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"]];
        
        field.text = self.curCar.classno;
        
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            /**
             *  车架号码点击事件
             */
            [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"bianjichejiahaoma"}];
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
        
        @strongify(self);
        [self showPicture:@"ins_eg_pic1"];
    } copy];
    
    HKCellData *cell2_3 = [HKCellData dataWithCellID:@"Field" tag:nil];
    cell2_3.customInfo[@"title"] = @"发动机号";
    cell2_3.customInfo[@"placehold"] = @"请填写发动机号";
    cell2_3.customInfo[@"howDisplay"] = @(YES);
    cell2_3.customInfo[@"block"] = [^(OETextField *field, RACSignal *stopSig) {
        @strongify(self);
        
        [field setNormalInputAccessoryViewWithDataArr:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"]];
        field.text = self.curCar.engineno;
        
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            /**
             *  发动机号
             */
            [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"bianjifadongjihao"}];
        }];
        
        [field setTextDidChangedBlock:^(CKLimitTextField *rFiled) {
            @strongify(self);
            
            NSString *temp = [rFiled.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            rFiled.text = [temp uppercaseString];
            self.curCar.engineno = rFiled.text;
        }];
        
    } copy];
    cell2_3.customInfo[@"howAction"] = [^(void){
        
        @strongify(self)
        [self showPicture:@"ins_eg_pic3"];
    } copy];
    
    HKCellData *cell2_4 = [HKCellData dataWithCellID:@"Field" tag:nil];
    cell2_4.customInfo[@"title"] = @"整车价格";
    cell2_4.customInfo[@"suffix"] = @"万";
    cell2_4.customInfo[@"block"] = [^(CKLimitTextField *field, RACSignal *stopSig) {
        @strongify(self);
        field.text = [NSString formatForPrice:self.curCar.price];
        field.keyboardType = UIKeyboardTypeDecimalPad;
        field.clearsOnBeginEditing = YES;
        field.textLimit = 12;
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"bianjizhengchejiage"}];
        }];
        
        [field setTextDidChangedBlock:^(CKLimitTextField *rFiled) {
            @strongify(self);
            if (rFiled.text.length > 0) {
                self.curCar.price = [rFiled.text floatValue];
            }
        }];
        
        [field setDidEndEditingBlock:^(CKLimitTextField *field) {
            @strongify(self);
            field.text = [NSString formatForPrice:self.curCar.price];
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
            [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"bianjixingshilicheng"}];
        }];
        
        [field setTextDidChangedBlock:^(CKLimitTextField *rFiled) {
            @strongify(self);
            if (rFiled.text.length > 0) {
                self.curCar.odo = [rFiled.text floatValue] * 10000;
            }
        }];
        
        [field setDidEndEditingBlock:^(CKLimitTextField *field) {
            @strongify(self);
            field.text = [NSString formatForPrice:self.curCar.odo / 10000.00];
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
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"bianjinianjiandaoqiri"}];
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
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"xuanzebaoxiangongsi"}];
        [self.view endEditing:YES];
        PickInsCompaniesVC *vc = [UIStoryboard vcWithId:@"PickInsCompaniesVC" inStoryboard:@"Car"];
        [vc setPickedBlock:^(NSString *name) {
            self.curCar.inscomp = name;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    HKCellData *cell2_8 = [HKCellData dataWithCellID:@"FlexCell" tag:nil];
    cell2_8.customInfo[@"img"] = @"flex_down_icon";
    [cell2_8 setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        @strongify(self);
        
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"zhankai"}];
        [self.view endEditing:YES];
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView * flexImageView = (UIImageView *)[cell searchViewWithTag:101];
        self.isMoreInfoExpand = !self.isMoreInfoExpand;
        [self reloadDatasource];
        
        NSMutableArray * indexPathArray = [NSMutableArray array];
        for (NSInteger i = 1;i< 9;i++)
        {
            [indexPathArray safetyAddObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        }
        if (self.isMoreInfoExpand)
        {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPathArray
                                  withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [flexImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI)];
            } completion:nil];
        }
        else
        {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPathArray
                                  withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [flexImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 0)];
            } completion:nil];
        }
    }];
    
    if (self.isMoreInfoExpand)
    {
        return @[cell2_0,cell1_2,cell2_1,cell2_2,cell2_3,cell2_4,cell2_5,cell2_6,cell2_7,cell2_8];
    }
    else
    {
        return @[cell2_0,cell2_8];
    }
}

#pragma mark - Action
- (void)actionSave:(id)sender
{
    [MobClick event:@"tianjiaaiche" attributes:@{@"navi" : @"baocun"}];
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
        
        if (self.jsBridgeFinishBlock)
        {
            //如果是网页进去，不需要pop，通知给jsbridge进行dismiss
            self.jsBridgeFinishBlock(self.curCar);
            return ;
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
    
    if (self.jsBridgeFinishBlock)
    {
        self.jsBridgeFinishBlock(nil);
        return;
    }
    
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
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"算了" color:kGrayTextColor clickBlock:^(id alertVC) {
            [MobClick event:@"tianjiaaiche" attributes:@{@"bianjidianquxiao" : @"suanle"}];
            CKAfter(0.1, ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"保存" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [MobClick event:@"tianjiaaiche" attributes:@{@"bianjidianquxiao" : @"baocun"}];
            [self actionSave:nil];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"您未保存信息，是否现在保存？" ActionItems:@[cancel,confirm]];
        [alert show];
    }
    else {
        [self.view endEditing:YES];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"放弃添加" color:kGrayTextColor clickBlock:^(id alertVC) {
            [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiadianquxiao" : @"fangqi"}];
            CKAfter(0.1, ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"继续添加" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiadianquxiao" : @"jixu"}];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"您未保存行驶证，需填写相关必填项并点击“保存”后方能添加爱车。" ActionItems:@[cancel,confirm]];
        [alert show];
    }
}

- (IBAction)actionDelete:(id)sender
{
    [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"shanchuaiche"}];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:kOrangeColor clickBlock:^(id alertVC) {
        
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
    }];
    
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您确定删除爱车吗？" ActionItems:@[cancel,confirm]];
    [alert show];
}

- (IBAction)actionUpload:(id)sender
{
    [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"yijianshangchuan"}];
    [self.model showImagePickerWithTargetVC:self];
    @weakify(self);
    [self.model setImagePickerBlock:^(RACSignal *signal) {
        [[signal initially:^{
            [gToast showingWithText:@"正在上传..."];
        }] subscribeNext:^(NSString *url) {
            @strongify(self);
            [gToast showSuccess:@"上传成功!"];
            self.curCar.licenceurl = url;
            self.curCar.status = 1;
            self.isDrivingLicenseNeedSave = YES;
            [self reloadDatasource];
            [self.tableView reloadData];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }];
}

-(void)actionBack:(id)sender
{
    [super actionBack:sender];
    [MobClick event:@"tianjiaaiche" attributes:@{@"navi" : @"back"}];
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
    NSInteger num = [[self.datasource safetyObjectAtIndex:section] count];
    return  num;
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
    else if ([data equalByCellID:@"FlexCell" tag:nil]) {
        [self resetFlexCell:cell withData:data];
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
    descL.numberOfLines = 2;
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
    [field setNormalInputAccessoryViewWithDataArr:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"]];
    field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    
    cell.contentView.userInteractionEnabled  = self.curCar.editMask & HKCarEditableEditPlateNumber;
    
    label.text = data.customInfo[@"title"];
    
    [chooseV setCornerRadius:5 withBorderColor:kDefTintColor borderWidth:0.5];
    chooseV.displayLb.text = self.curCar.licenceArea.length ? self.curCar.licenceArea : [self getCurrentProvince];
    @weakify(self);
    [[[chooseV rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
         @strongify(self);
         [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"chepaidiyu"}];
         CollectionChooseVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"CollectionChooseVC"];
         HKNavigationController *nav = [[HKNavigationController alloc] initWithRootViewController:vc];
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
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"bianjichepai"}];
        field.placeholder = nil;
    }];
    
    [field setDidEndEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = @"填写车牌";
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
    UIImageView *arrow = [cell viewWithTag:1003];
    
    BOOL disable = [data.customInfo[@"disable"] boolValue];
    cell.selectionStyle = disable ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    arrow.hidden = disable;
    
    label.text = data.customInfo[@"title"];
    
    field.placeholder = data.customInfo[@"placehold"];
    [field mas_updateConstraints:^(MASConstraintMaker *make) {
        if (disable) {
            make.right.equalTo(self.view).offset(-14);
        }
        else {
            make.right.equalTo(arrow.mas_left).offset(-8);
        }
    }];
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
    field.placeholder = data.customInfo[@"placehold"];
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
    switchV.on = self.curCar.isDefault;
    @weakify(self);
    [[switchV rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *sw) {
        @strongify(self);
        [MobClick event:@"tianjiaaiche" attributes:@{@"tianjiaaiche" : @"morencheliang"}];
        BOOL on = sw.on;
        self.curCar.isDefault = on;
    }];
}

- (void)resetFlexCell:(UITableViewCell *)cell withData:(HKCellData *)data
{
    UIImageView * imgView = (UIImageView *)[cell searchViewWithTag:101];
    imgView.image = [UIImage imageNamed:data.customInfo[@"img"]];
    [imgView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, self.isMoreInfoExpand ? M_PI : 0)];
}

#pragma mark - Utility
- (void)showPickAutomobileBrandVC
{
    @weakify(self)
    if (self.curCar.brand.length == 0)
    {
        PickAutomobileBrandVC *vc = [UIStoryboard vcWithId:@"PickerAutomobileBrandVC" inStoryboard:@"Car"];
        vc.originVC = self;
        [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel *series, AutoDetailModel *model) {
            
            @strongify(self)
            
            self.curCar.brandid = brand.brandid;
            self.curCar.brand = brand.brandname;
            self.curCar.brandLogo = brand.brandLogo;
            self.curCar.seriesModel = series;
            self.curCar.detailModel = model;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

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
