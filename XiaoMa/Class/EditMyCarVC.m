//
//  EditMyCarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EditMyCarVC.h"
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


@interface EditMyCarVC ()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HKMyCar *curCar;
@property (nonatomic, assign) BOOL isEditingModel;
@property (nonatomic, assign) BOOL showHeaderView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;

@property (nonatomic, strong) DatePickerVC *datePicker;
@property (nonatomic, assign) BOOL isDrivingLicenseNeedSave;
@end

@implementation EditMyCarVC
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
    [MobClick beginLogPageView:@"rp312"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp312"];
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
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
    left.tintColor = HEXCOLOR(@"#262626");
    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.rightBarButtonItem = right;
}

- (void)setupTableView
{
    self.showHeaderView = self.originCar.status == 0 || self.originCar.status == 3;
    
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
    
    if (self.model.allowAutoChangeSelectedCar || !_isEditingModel || !(self.curCar.editMask & HKCarEditableDelete)) {
        [self.bottomBar removeFromSuperview];
    }
    
    [self.tableView reloadData];
}
#pragma mark - Action
- (void)actionSave:(id)sender
{
    [MobClick event:@"rp312-12"];
    if ([self sharkCellIfErrorAtIndex:0 withData:self.curCar.licenceSuffix errorMsg:@"车牌号码不能为空"]) {
        return;
    }
    
    if (![MyCarStore verifiedLicenseNumberFrom:self.curCar.licenceSuffix]) {
        [self sharkCellIfErrorAtIndex:0 withData:nil errorMsg:@"请输入正确的车牌号码"];
        return;
    }
    if ([self sharkCellIfErrorAtIndex:1 withData:self.curCar.purchasedate errorMsg:@"购车时间不能为空"]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:2 withData:self.curCar.brand errorMsg:@"品牌车系不能为空"]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:3 withData:self.curCar.detailModel.modelname errorMsg:@"具体车型不能为空"]) {
        return;
    }
    
    MyCarStore *store = [MyCarStore fetchOrCreateStore];
    HKStoreEvent *evt = self.isEditingModel ? [store updateCar:self.curCar] : [store addCar:self.curCar];
    @weakify(self);
    [[[[store sendEvent:evt] signal] initially:^{
        
        [gToast showingWithText:@"正在保存..."];
    }] subscribeNext:^(id x) {
        
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

- (void) actionCancel:(id)sender
{
    [MobClick event:@"312-13"];
    
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您未保存信息，是否现在保存？" delegate:nil
                                              cancelButtonTitle:@"算了" otherButtonTitles:@"保存", nil];
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
            //算了
            if ([number integerValue] == 0) {
                [MobClick event:@"rp312-14"];
                CKAfter(0.1, ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            //保存
            else {
                [MobClick event:@"rp312-15"];
                [self actionSave:nil];
            }
        }];
        [alert show];
    }
    else {
        [self.view endEditing:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您未保存行驶证，需填写相关必填项并点击“保存”后方能添加爱车。"
                                                       delegate:nil cancelButtonTitle:@"放弃添加" otherButtonTitles:@"继续添加", nil];
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
            //放弃
            if ([number integerValue] == 0) {
                [MobClick event:@"rp312-16"];
                CKAfter(0.1, ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            //继续
            else {
                [MobClick event:@"rp312-17"];
            }
        }];
        [alert show];
    }
}

- (IBAction)actionDelete:(id)sender
{
    [MobClick event:@"rp312-11"];
    //添加模式,点击删除直接返回上一页
    if (!self.isEditingModel) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    MyCarStore *store = [MyCarStore fetchOrCreateStore];
    [[[[store sendEvent:[store removeCarByID:self.curCar.carId]] signal] initially:^{
        
        [gToast showingWithText:@"正在删除..."];
    }] subscribeNext:^(id x) {
        
        [gToast showSuccess:@"删除成功!"];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
    
}

- (IBAction)actionUpload:(id)sender
{
    [MobClick event:@"rp312-1"];
    @weakify(self);
    [[self.model rac_uploadDrivingLicenseWithTargetVC:self initially:^{
        [gToast showingWithText:@"正在上传..."];
    }] subscribeNext:^(NSString *url) {
        @strongify(self);
        [gToast showSuccess:@"上传成功!"];
        self.curCar.licenceurl = url;
        self.curCar.status = 1;
        self.showHeaderView = NO;
        self.isDrivingLicenseNeedSave = YES;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.showHeaderView) {
        return 84;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.showHeaderView) {
        return 1;
    }
    return self.curCar ? 9 : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.showHeaderView ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0 && self.showHeaderView) {
        cell = [self cellForHeaderViewAtIndexPath:indexPath];
    }
    else if (indexPath.row == 0)
    {
        cell = [self cellForLicenceAtIndexPath:indexPath];
    }
    else if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 7) {
        cell = [self cellForType2AtIndexPath:indexPath];
    }
    else if (indexPath.row == 8) {
        cell = [self cellForType3AtIndexPath:indexPath];
    }
    else {
        cell = [self cellForType1AtIndexPath:indexPath];
    }
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell setCustomSeparatorInset:UIEdgeInsetsZero];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //购车时间
    if (indexPath.row == 1) {
        [MobClick event:@"rp312-3"];
        [self.view endEditing:YES];
        self.datePicker.maximumDate = [NSDate date];
        
        NSDate *selectedDate = self.curCar.purchasedate ? self.curCar.purchasedate : [NSDate date];
        @weakify(self);
        [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:selectedDate]
         subscribeNext:^(NSDate *date) {
             @strongify(self);
             self.curCar.purchasedate = date;
         }];
    }
    //年检到期日
    else if (indexPath.row == 6) {
        [MobClick event:@"rp312-8"];
        [self.view endEditing:YES];
        @weakify(self);
        self.datePicker.maximumDate = nil;
        NSDate *date = self.curCar.insexipiredate ? self.curCar.insexipiredate : [NSDate date];
        [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:date]
         subscribeNext:^(NSDate *date) {
             
             @strongify(self);
             self.curCar.insexipiredate = date;
         }];
    }
    //汽车品牌
    else if (indexPath.row == 2) {
        [MobClick event:@"rp312-4"];
        [self.view endEditing:YES];
        PickAutomobileBrandVC *vc = [UIStoryboard vcWithId:@"PickerAutomobileBrandVC" inStoryboard:@"Car"];
        vc.originVC = self;
        [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel *series, AutoDetailModel * model) {
            self.curCar.brand = brand.brandname;
            self.curCar.brandid = brand.brandid;
            self.curCar.seriesModel = series;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //具体车系
    else if (indexPath.row == 3) {
        [MobClick event:@"rp312-5"];
        [self.view endEditing:YES];
        PickerAutoModelVC *vc = [UIStoryboard vcWithId:@"PickerAutoModelVC" inStoryboard:@"Car"];
        vc.originVC = self;
        [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel *series, AutoDetailModel * model) {
            self.curCar.detailModel = model;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //保险公司
    else if (indexPath.row == 7) {
        [MobClick event:@"rp312-9"];
        [self.view endEditing:YES];
        PickInsCompaniesVC *vc = [UIStoryboard vcWithId:@"PickInsCompaniesVC" inStoryboard:@"Car"];
        [vc setPickedBlock:^(NSString *name) {
            self.curCar.inscomp = name;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
        if ([field isKindOfClass:[UITextField class]] && field.userInteractionEnabled == YES) {
            [field becomeFirstResponder];
        }
    }
}

#pragma mark - Cell
- (UITableViewCell *)cellForHeaderViewAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    UIButton *uploadBtn = (UIButton *)[cell.contentView viewWithTag:1003];
    [self.model setupUploadBtn:uploadBtn andDescLabel:descLabel forCar:self.originCar];
    
    @weakify(self);
    [[[uploadBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self actionUpload:nil];
    }];
    
    return cell;
}

- (JTTableViewCell *)cellForLicenceAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"LicenceCell" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    [field mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(200);
    }];
    UILabel *unitL = (UILabel *)[cell.contentView viewWithTag:1003];
    ProvinceChooseView * paramView = (ProvinceChooseView * )[cell searchViewWithTag:1004];
    
    HKMyCar *car = self.curCar;
    paramView.displayLb.text = self.curCar.licenceArea.length ? self.curCar.licenceArea : [self getCurrentProvince];
    
    field.delegate = self;
    field.keyboardType = UIKeyboardTypeDefault;
    field.customObject = indexPath;
    BOOL fieldEditable = YES;
    if (indexPath.row == 0) {
        titleL.attributedText = [self attrStrWithTitle:@"车牌号码" asterisk:YES];
        field.text = car.licenceSuffix;
        unitL.text = nil;
        fieldEditable = car.editMask & HKCarEditableEdit;
        paramView.userInteractionEnabled = fieldEditable;
        field.userInteractionEnabled = fieldEditable;
        [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            car.licenceSuffix = [x uppercaseString];
        }];
    }
    
    
    [[[paramView rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        CollectionChooseVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"CollectionChooseVC"];
        JTNavigationController *nav = [[JTNavigationController alloc] initWithRootViewController:vc];
        vc.datasource = gAppMgr.getProvinceArray;
        [vc setSelectAction:^(NSDictionary * d) {
            
            NSString * key = [d.allKeys safetyObjectAtIndex:0];
            self.curCar.licenceArea = key;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    }];
    
    return cell;
}

- (JTTableViewCell *)cellForType1AtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    UILabel *unitL = (UILabel *)[cell.contentView viewWithTag:1003];
    
    HKMyCar *car = self.curCar;
    
    field.delegate = self;
    field.keyboardType = UIKeyboardTypeDefault;
    field.clearsOnBeginEditing = NO;
    field.customObject = indexPath;
    BOOL fieldEditable = YES;
    if (indexPath.row == 0) {
        titleL.attributedText = [self attrStrWithTitle:@"车牌号码" asterisk:YES];
        field.text = car.licenceSuffix;
        unitL.text = nil;
        fieldEditable = car.editMask & HKCarEditableEdit;
        [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            car.licenceSuffix = [x uppercaseString];
        }];
    }
    else  if (indexPath.row  == 1) {
        unitL.text = nil;
        titleL.attributedText = [self attrStrWithTitle:@"购车时间" asterisk:YES];
        [[RACObserve(car, purchasedate) takeUntilForCell:cell] subscribeNext:^(NSDate *date) {
            field.text = [date dateFormatForYYMMdd];
        }];
        fieldEditable = NO;
    }
    else  if (indexPath.row  == 4) {
        unitL.text = @"万元";
        titleL.attributedText = [self attrStrWithTitle:@"整车价格" asterisk:NO];
        field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        field.clearsOnBeginEditing = YES;
        field.text = [NSString stringWithFormat:@"%.2f", car.price];
        
        [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString *str) {
            if (str.length > 0) {
                car.price = [str floatValue];
            }
        }];
    }
    else if (indexPath.row == 5) {
        unitL.text = @"万公里";
        titleL.attributedText = [self attrStrWithTitle:@"当前里程" asterisk:NO];
        field.keyboardType = UIKeyboardTypeDecimalPad;
        field.clearsOnBeginEditing = YES;
        field.text = [NSString formatForPrice:car.odo];
        
        [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString *str) {
            if (str.length > 0) {
                car.odo = [str floatValue];
            }
        }];
    }
    else if (indexPath.row == 6) {
        unitL.text = nil;
        titleL.attributedText = [self attrStrWithTitle:@"年检到期日" asterisk:NO];
        @weakify(field);
        [[RACObserve(car, insexipiredate) takeUntilForCell:cell] subscribeNext:^(NSDate *date) {
            @strongify(field);
            field.text = [date dateFormatForYYMMdd];
        }];
        fieldEditable = NO;
    }
    
    field.userInteractionEnabled = fieldEditable;
    return cell;
}

- (JTTableViewCell *)cellForType2AtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *subTitleL = (UILabel *)[cell.contentView viewWithTag:1002];
    
    if (indexPath.row == 2) {
        titleL.attributedText = [self attrStrWithTitle:@"品牌车系" asterisk:YES];
        [[RACObserve(self.curCar, brand) takeUntilForCell:cell] subscribeNext:^(id x) {
            subTitleL.text = [NSString stringWithFormat:@"%@ %@", x, self.curCar.seriesModel.seriesname];
        }];
        [[RACObserve(self.curCar, seriesModel) takeUntilForCell:cell] subscribeNext:^(AutoSeriesModel * series) {
            subTitleL.text = [NSString stringWithFormat:@"%@ %@", self.curCar.brand, series.seriesname];
        }];
    }
    else if (indexPath.row == 3) {
        titleL.attributedText = [self attrStrWithTitle:@"具体车型" asterisk:YES];
        [[RACObserve(self.curCar, seriesModel) takeUntilForCell:cell] subscribeNext:^(AutoDetailModel * detailModel) {
            subTitleL.text = detailModel.modelname;
        }];
    }
    else if (indexPath.row == 7) {
        titleL.attributedText = [self attrStrWithTitle:@"保险公司" asterisk:NO];
        [[RACObserve(self.curCar, inscomp) takeUntilForCell:cell] subscribeNext:^(id x) {
            subTitleL.text = self.curCar.inscomp;
        }];
    }
    return cell;
}

- (JTTableViewCell *)cellForType3AtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"Cell3" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UISwitch *switchV = (UISwitch *)[cell.contentView viewWithTag:1002];
    
    titleL.text = @"设为默认车辆";
    switchV.on = self.curCar.isDefault;
    @weakify(self);
    [[switchV rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *sw) {
        
        @strongify(self);
        [MobClick event:@"rp312-10"];
        BOOL on = sw.on;
        self.curCar.isDefault = on;
    }];
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger length = range.location + [string length] - range.length;
    NSIndexPath *indexPath = textField.customObject;
    //车牌号码
    if (indexPath.row == 0 && length > 10) {
        return NO;
    }
    //当前里程
    else if (indexPath.row == 5 && length >= 12) {
        return NO;
    }
    //整车价格
    else if (indexPath.row == 4 && length >= 12) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = textField.customObject;
    if (indexPath.row == 0) {
        [MobClick event:@"rp312-2"];
    }
    else if (indexPath.row == 4) {
        [MobClick event:@"rp312-6"];
    }
    else if (indexPath.row == 5) {
        [MobClick event:@"rp312-7"];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = textField.customObject;
    HKMyCar *car = self.curCar;
    if (indexPath.row == 0) {
        textField.text = car.licenceSuffix;
    }
    else if (indexPath.row == 4) {
        textField.text = [NSString stringWithFormat:@"%.2f", car.price];
    }
    else if (indexPath.row == 5) {
        textField.text = [NSString formatForPrice:car.odo];
    }
}

#pragma mark - Utility
- (BOOL)sharkCellIfErrorAtIndex:(NSInteger)index withData:(id)data errorMsg:(NSString *)msg
{
    if (!data || [data isKindOfClass:[NSString class]] ? [(NSString *)data length] == 0 : NO) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:self.showHeaderView ? 1 : 0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [gToast showError:msg];
        return YES;
    }
    return NO;
}

- (NSAttributedString *)attrStrWithTitle:(NSString *)title asterisk:(BOOL)asterisk
{
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedString];
    NSAttributedString *titleStr = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor darkTextColor]}];
    [attrStr appendAttributedString:titleStr];
    if (asterisk) {
        NSAttributedString *asteriskStr = [[NSAttributedString alloc] initWithString:@"*" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor redColor]}];
        [attrStr appendAttributedString:asteriskStr];
    }
    
    return attrStr;
}

- (NSAttributedString *)attrStrWithTitle:(NSString *)title mark:(NSString *)mark
{
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedString];
    NSAttributedString *titleStr = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor darkTextColor]}];
    [attrStr appendAttributedString:titleStr];
    if (mark) {
        NSAttributedString *asteriskStr = [[NSAttributedString alloc] initWithString:mark attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor darkTextColor]}];
        [attrStr appendAttributedString:asteriskStr];
    }
    
    return attrStr;
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

@end
