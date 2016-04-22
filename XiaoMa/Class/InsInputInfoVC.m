//
//  InsInputInfoVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsInputInfoVC.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"
#import "GetInsBaseCarListOp.h"
#import "GetInsBaseCarListByIDOp.h"
#import "AddInsCarBaseInfoOp.h"
#import "NSDate+DateForText.h"
#import "InsuranceStore.h"
#import "UIView+Shake.h"
#import "IQKeyboardManager.h"
#import "CarIDCodeCheckModel.h"

#import <MZFormSheetController.h>
#import "DatePickerVC.h"
#import "InsuranceInfoSubmitingVC.h"
#import "CityPickerVC.h"
#import "InsInputDateVC.h"

@interface InsInputInfoVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) DatePickerVC *datePicker;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) InsBaseCar *baseCar;
@property (nonatomic, strong) HKCellData *transferDate;
@property (nonatomic, strong) NSString *curProvince;
@end

@implementation InsInputInfoVC

- (void)awakeFromNib
{
    if (!self.insModel) {
        self.insModel = [[InsuranceVM alloc] init];
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"InsInputInfoVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDatePicker];
    CKAsyncMainQueue(^{
        [self loadDataAsync];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].disableSpecialCaseForScrollView = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].disableSpecialCaseForScrollView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置日期选择控件（主要是为了事先加载，优化性能）
- (void)setupDatePicker {
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
}

#pragma mark - Datasource
- (void)loadDataAsync
{
    RACSignal *signal;
    @weakify(self);
    if ([self.insModel.simpleCar.carpremiumid integerValue] == 0) {
        GetInsBaseCarListOp *op = [GetInsBaseCarListOp operation];
        op.req_name = self.insModel.realName;
        op.req_licensenum = self.insModel.simpleCar.licenseno;
        op.req_carid = self.insModel.simpleCar.carid ? self.insModel.simpleCar.carid : @0;
        signal = [op rac_postRequest];
    }
    else {
        GetInsBaseCarListByIDOp *op = [GetInsBaseCarListByIDOp operation];
        op.req_carpremiumid = self.insModel.simpleCar.carpremiumid;
        signal = [[op rac_postRequest] doNext:^(GetInsBaseCarListByIDOp *op) {
            @strongify(self);
            self.insModel.realName = op.rsp_basecar.name;
            self.curProvince = op.rsp_basecar.province;
        }];
    }

    [[[signal initially:^{
        
        @strongify(self);
        self.containerView.hidden = YES;
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
      
        @strongify(self);
        [self.view stopActivityAnimation];
        self.containerView.hidden = NO;
        [self reloadData];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.baseCar = [x rsp_basecar];
    }];
}

- (void)reloadData
{
    NSMutableArray *datasource = [NSMutableArray array];
    //车牌
    HKCellData *numberCell = [HKCellData dataWithCellID:@"Number" tag:nil];
    numberCell.object = self.insModel.simpleCar.licenseno;
    [numberCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 48;
    }];
    [datasource addObject:numberCell];
    
    //行使城市/注册日期
    HKCellData *doubleCell = [HKCellData dataWithCellID:@"Double" tag:nil];
    doubleCell.customInfo[@"city"] = self.baseCar.city;
    doubleCell.customInfo[@"date"] = self.baseCar.regdate;
    doubleCell.customInfo[@"pic"] = @"ins_eg_pic4";
    [datasource addObject:doubleCell];
    
    //车架号
    HKCellData *normalCell1 = [HKCellData dataWithCellID:@"Normal" tag:nil];
    normalCell1.customInfo[@"title"] = @"车架号码";
    normalCell1.customInfo[@"subTitle"] = @" (车辆识别代号)";
    normalCell1.customInfo[@"placehold"] = @"请输入车架号码";
    normalCell1.customInfo[@"pic"] = @"ins_eg_pic1";
    normalCell1.customInfo[@"limit"] = @17;
    normalCell1.customInfo[@"field.event"] = @"rp1001_4";
    normalCell1.customInfo[@"help.event"] = @"rp1001_3";
    normalCell1.customInfo[@"textfield.datasource"] = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    normalCell1.object = self.baseCar.frameno;
    [datasource addObject:normalCell1];
    
    //车辆型号
    HKCellData *normalCell2 = [HKCellData dataWithCellID:@"Normal" tag:nil];
    normalCell2.customInfo[@"title"] = @"车辆型号";
    normalCell2.customInfo[@"subTitle"] = @" (品牌型号非中文部分)";
    normalCell2.customInfo[@"placehold"] = @"请输入车辆型号";
    normalCell2.customInfo[@"pic"] = @"ins_eg_pic2";
    normalCell2.customInfo[@"limit"] = @50;
    normalCell2.customInfo[@"field.event"] = @"rp1001_6";
    normalCell2.customInfo[@"help.event"] = @"rp1001_5";
    normalCell2.customInfo[@"textfield.datasource"] = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    normalCell2.object = self.baseCar.brandname;
    [datasource addObject:normalCell2];
    
    //发动机号
    HKCellData *normalCell3 = [HKCellData dataWithCellID:@"Normal" tag:nil];
    normalCell3.customInfo[@"title"] = @"发动机号";
    normalCell3.customInfo[@"placehold"] = @"请输入发动机号";
    normalCell3.customInfo[@"pic"] = @"ins_eg_pic3";
    normalCell3.customInfo[@"limit"] = @50;
    normalCell3.customInfo[@"field.event"] = @"rp1001_8";
    normalCell3.customInfo[@"help.event"] = @"rp1001_7";
    normalCell3.customInfo[@"textfield.datasource"] = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    normalCell3.object = self.baseCar.engineno;
    [datasource addObject:normalCell3];

    //过户车辆
    HKCellData *switchCell = [HKCellData dataWithCellID:@"Switch" tag:nil];
    switchCell.object = @(self.baseCar.transferflag);
    [switchCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 50;
    }];
    [datasource addObject:switchCell];

    //过户日期
    self.transferDate = [HKCellData dataWithCellID:@"Date" tag:nil];
    self.transferDate.object = self.baseCar.transferdate;
    [self.transferDate setHeightBlock:^CGFloat(UITableView *tableView) {
        return 44;
    }];
    if (self.baseCar.transferflag) {
        [datasource addObject:self.transferDate];
    }
    
    //达达帮忙
    HKCellData *helpCell = [HKCellData dataWithCellID:@"Help" tag:nil];
    [helpCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 57;
    }];
    @weakify(self);
    [helpCell setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        
        @strongify(self);
        [MobClick event:@"rp1001_11"];
        InsuranceInfoSubmitingVC *vc = [UIStoryboard vcWithId:@"InsuranceInfoSubmitingVC" inStoryboard:@"Insurance"];
        vc.insModel = self.insModel;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [datasource addObject:helpCell];
    
    self.datasource = datasource;
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1001_13"];
    if (self.insModel.originVC) {
        [self.navigationController popToViewController:self.insModel.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)actionNext:(id)sender
{
    [MobClick event:@"rp1001_12"];
    AddInsCarBaseInfoOp *op = [AddInsCarBaseInfoOp operation];
    op.req_city = [[self.datasource safetyObjectAtIndex:1] customInfo][@"city"];
    op.req_regdate = [[self.datasource safetyObjectAtIndex:1] customInfo][@"date"];
    op.req_frameno = [(HKCellData *)[self.datasource safetyObjectAtIndex:2] object];
    op.req_brandname = [(HKCellData *)[self.datasource safetyObjectAtIndex:3] object];
    op.req_engineno = [(HKCellData *)[self.datasource safetyObjectAtIndex:4] object];
    op.req_transferflag = [[(HKCellData *)[self.datasource safetyObjectAtIndex:5] object] boolValue];
    op.req_transferdate = op.req_transferflag == 1 ? [(HKCellData *)[self.datasource safetyObjectAtIndex:6] object] : nil;
    op.req_carpremiumid = self.insModel.simpleCar.carpremiumid;
    //错误判断
    if (op.req_city.length == 0) {
        [gToast showText:@"行驶城市不能为空"];
    }
    else if (op.req_regdate.length == 0) {
        [gToast showText:@"注册日期不能为空"];
    }
    else if (op.req_frameno.length != 17) {
        [gToast showText:@"车架号位数必须为17位"];
    }
    else if (![CarIDCodeCheckModel carIDCheckWithCodeStr:op.req_frameno]) {
        [gToast showText:@"请输入正确的车架号"];
    }
    else if (op.req_brandname.length == 0) {
        [gToast showText:@"车辆型号不能为空"];
    }
    else if (op.req_engineno.length == 0) {
        [gToast showText:@"发动机号不能为空"];
    }
    else if (op.req_transferflag == 1 && op.req_transferdate.length == 0) {
        [gToast showText:@"过户时期不能为空"];
    }
    else {
        //补全剩余信息
        op.req_licensenum = self.insModel.simpleCar.licenseno;
        op.req_name = self.insModel.realName;
        op.req_province = self.curProvince;
        
        //开始请求
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"正在提交..."];
        }] subscribeNext:^(AddInsCarBaseInfoOp *op) {
            
            @strongify(self);
            [gToast dismiss];
            //更新当前保险车辆信息（id和status）
            self.insModel.simpleCar.carpremiumid = op.rsp_carpremiumid;
            self.insModel.simpleCar.status = 3;
            [[[InsuranceStore fetchExistsStore] getInsSimpleCars] sendAndIgnoreError];
            
            //跳转到险种选择页面
            InsInputDateVC *vc = [UIStoryboard vcWithId:@"InsInputDateVC" inStoryboard:@"Insurance"];
            vc.insModel = self.insModel;
            vc.insModel.numOfSeat = op.rsp_seatcount;
            vc.insModel.startDate = op.rsp_mstartdate;
            vc.insModel.forceStartDate = op.rsp_fstartdate;
            [self.navigationController pushViewController:vc animated:YES];
        } error:^(NSError *error) {
            
            [gToast showError:error.domain];
        }];
    }
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    if (data.selectedBlock) {
        data.selectedBlock(tableView, indexPath);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Number" tag:nil]) {
        [self resetLicenseNumberCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Double" tag:nil]) {
        [self resetDoubleItemCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Normal" tag:nil]) {
        [self resetNormalCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Switch" tag:nil]) {
        [self resetSwitchCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Date" tag:nil]) {
        [self resetDateCell:cell forData:data];
    }

    return cell;
}

#pragma mark - Cell
- (void)resetLicenseNumberCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *label = [cell viewWithTag:1001];
    label.text = data.object;
}

- (void)resetDoubleItemCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    HKSubscriptInputField *cityInput = [cell viewWithTag:10012];
    UIButton *cityB = [cell viewWithTag:10013];
    HKSubscriptInputField *dateInput = [cell viewWithTag:10022];
    UIButton *dateB = [cell viewWithTag:10023];
    UIButton *helpB = [cell viewWithTag:10024];
    
    cityInput.inputField.text = data.customInfo[@"city"];
    cityInput.inputField.placeholder = @"请选择城市";
    cityInput.subscriptImageName = @"ins_arrow_point";
    
    dateInput.inputField.text = data.customInfo[@"date"];
    dateInput.inputField.placeholder = @"请选择日期";
    dateInput.subscriptImageName = @"ins_arrow_time";

    @weakify(self);
    [[[cityB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
         @strongify(self);
         [MobClick event:@"rp1001_2"];
         [self.view endEditing:YES];
         CityPickerVC *vc = [CityPickerVC cityPickerVCWithOriginVC:self];
         vc.options = CityPickerOptionCity;
         InsuranceStore *store = [InsuranceStore fetchOrCreateStore];
         if (store.insProvinces.count > 1) {
             vc.options = vc.options | CityPickerOptionProvince;
         }
         else {
             vc.parentArea = [store.insProvinces objectAtIndex:0];
         }
         [vc setCompletedBlock:^(CityPickerVC *vc, Area *p, Area *c, Area *d) {
             
             @strongify(self);
             self.curProvince = p.name ? p.name : vc.parentArea.name;
             cityInput.inputField.text = c.name;
             data.customInfo[@"city"] = c.name;
         }];
         [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[[[dateB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     flattenMap:^RACStream *(id value) {
         
         @strongify(self);
         [MobClick event:@"rp1001_1"];
         [self.view endEditing:YES];
         return [self rac_pickDateWithNow:data.customInfo[@"date"]];
     }] subscribeNext:^(NSString *datetext) {
         
         data.customInfo[@"date"] = datetext;
         dateInput.inputField.text = datetext;
     }];
    
    //显示帮助
    [[[helpB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
         @strongify(self);
         [MobClick event:@"rp1001_14"];
         [self showPicture:data.customInfo[@"pic"]];
     }];
}

- (void)resetNormalCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *titleL = [cell viewWithTag:10011];
    UIButton *helpB = [cell viewWithTag:10012];
    HKSubscriptInputField *inputF = [cell viewWithTag:10013];
    
    //标题
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedString];
    NSAttributedString *titleStr = [[NSAttributedString alloc] initWithString:data.customInfo[@"title"] attributes:
                                    @{NSFontAttributeName: [UIFont systemFontOfSize:15],
                                      NSForegroundColorAttributeName: kDefTintColor}];
    [attrStr appendAttributedString:titleStr];
    NSString *subTitle = data.customInfo[@"subTitle"];
    if (subTitle) {
        NSAttributedString *subTitleStr = [[NSAttributedString alloc] initWithString:subTitle attributes:
                                           @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                             NSForegroundColorAttributeName: kGrayTextColor}];
        [attrStr appendAttributedString:subTitleStr];
    }
    titleL.attributedText = attrStr;
    
    //输入框
    inputF.inputField.placeholder = data.customInfo[@"placehold"];
    inputF.inputField.text = data.object;
    inputF.inputField.keyboardType = UIKeyboardTypeASCIICapable;
    inputF.inputField.textLimit = [data.customInfo[@"limit"] integerValue];
    NSArray * array = data.customInfo[@"textfield.datasource"];
    if (array.count)
    {
        [inputF.inputField setNormalInputAccessoryViewWithDataArr:array];
    }
    [inputF.inputField setDidBeginEditingBlock:^(CKLimitTextField *field) {
        [MobClick event:data.customInfo[@"field.event"]];
    }];
    [inputF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {

        NSString *text = [field.text uppercaseString];
        field.text = text;
        data.object = text;
    }];
    
    //显示帮助
    @weakify(self);
    [[[helpB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
      subscribeNext:^(id x) {
          
          @strongify(self);
          [MobClick event:data.customInfo[@"help.event"]];
          [self showPicture:data.customInfo[@"pic"]];
    }];
}

- (void)resetSwitchCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UISwitch *switchV = [cell viewWithTag:1002];
    switchV.on = [data.object boolValue];
    @weakify(self);
    @weakify(switchV);
    [[[switchV rac_signalForControlEvents:UIControlEventValueChanged] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(NSNumber *x) {
         
         @strongify(self);
         [MobClick event:@"rp1001_9"];
         @strongify(switchV);
         BOOL on = switchV.on;
         data.object = @(on);
         HKCellData *nextData = [self.datasource safetyObjectAtIndex:6];
         if (on && ![nextData equalByCellID:@"Date" tag:nil]) {
             [self.datasource safetyInsertObject:self.transferDate atIndex:6];
             [self.tableView beginUpdates];
             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
             [self.tableView endUpdates];
         }
         else if (!on && [nextData equalByCellID:@"Date" tag:nil]) {
             [self.datasource safetyRemoveObjectAtIndex:6];
             [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
             [self.tableView endUpdates];
         }
    }];
}

- (void)resetDateCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    HKSubscriptInputField *inputF = [cell viewWithTag:1002];
    UIButton *inputB = [cell viewWithTag:1003];
    
    inputF.inputField.placeholder = @"请选择过户日期";
    inputF.inputField.text = data.object;
    inputF.subscriptImageName = @"ins_arrow_time";
    
    @weakify(self);
    [[[[inputB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
      flattenMap:^RACStream *(id value) {
          
        @strongify(self);
        [MobClick event:@"rp1001_10"];
        return [self rac_pickDateWithNow:data.object];
    }] subscribeNext:^(NSString *datetext) {
        
        data.object = datetext;
        inputF.inputField.text = datetext;
    }];
}

#pragma mark - Utility
- (RACSignal *)rac_pickDateWithNow:(NSString *)nowtext
{
    NSDate *date = [NSDate dateWithD10Text:nowtext];
    self.datePicker.maximumDate = [NSDate date];
    return [[[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:date] ignoreError] map:^id(NSDate *date) {
        return [date dateFormatForD10];
    }];
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

@end
