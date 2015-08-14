//
//  enquiryInsuranceVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EnquiryInsuranceVC.h"
#import "XiaoMa.h"
#import <Masonry.h>
#import "MonthPickerVC.h"
#import "UIView+Shake.h"
#import "EnquiryResultVC.h"
#import "GetInsuranceCalculatorOp.h"
#import "NSDate+DateForText.h"

@interface EnquiryInsuranceVC ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
///新车未上牌的一个标志
@property (nonatomic, assign) BOOL noPlateNumber;
///车牌号
@property (nonatomic, strong) NSString *plateNumber;
///城市
@property (nonatomic, strong) NSString *city;
///价格
@property (nonatomic, strong) NSString *price;
///提车时间
@property (nonatomic, strong) NSDate *carryTime;
@property (nonatomic, strong) MonthPickerVC *datePickerVC;

@property (nonatomic, strong) CKSegmentHelper *carPicker;
@property (nonatomic, assign) BOOL shouldHideHeaderView;
@property (nonatomic, assign) HKMyCar *selectedCar;
@property (nonatomic, strong) NSArray *carList;
@property (nonatomic, assign) BOOL isLoadingCars;
@property (nonatomic, assign) BOOL isLoadingCarsFail;
@end

@implementation EnquiryInsuranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatePickerVC];
    CKAsyncMainQueue(^{
        [self reloadCarList];
        [self reloadDatasource];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp115"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp115"];
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

- (void)setupDatePickerVC
{
    self.datePickerVC = [MonthPickerVC monthPickerVC];
    [self addChildViewController:self.datePickerVC];
}

- (void)reloadCarList
{
    @weakify(self);
    RACSignal *signal = [RACSignal return:nil];
    
    if (gAppMgr.myUser.carModel) {
        signal = [[signal flattenMap:^RACStream *(id value) {
            return [gAppMgr.myUser.carModel rac_fetchDataIfNeeded];
        }] map:^id(JTQueue *queue) {
            return [queue allObjects];
        }];
    }
    
    [[[signal initially:^{
        
        @strongify(self);
        self.isLoadingCars = YES;
    }] finally:^{
      
        @strongify(self);
        self.isLoadingCars = NO;
    }] subscribeNext:^(JTQueue *queue) {
        
        @strongify(self);
        self.carList = [queue allObjects];
        if (self.carList.count == 0) {
            self.shouldHideHeaderView = YES;
        }
        else {
            [self resetCarPicker];
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        self.isLoadingCarsFail = YES;
    }];
}

- (void)resetCarPicker
{
    self.carPicker = [[CKSegmentHelper alloc] init];
    @weakify(self);
    [self.carPicker addItems:self.carList forGroupName:@"car" withChangedBlock:^(HKMyCar *car, BOOL selected) {
        
        @strongify(self);
        if (selected) {
            if (car.price > 0) {
                self.price = [NSString stringWithFormat:@"%.2f", car.price];
            }
            self.plateNumber = car.licencenumber;
            self.carryTime = car.purchasedate;
            self.selectedCar = car;
        }

        //更新ui
        UIButton *plateBtn = car.customInfo[@"btn"];
        [self setPlateNumberButton:plateBtn selected:selected forCar:car];
    }];
}

- (void)reloadDatasource
{
    //提车时间
    self.city = gMapHelper.addrComponent.city;
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionEnquiry:(id)sender
{
    [MobClick event:@"rp115-7"];
    
    // 检测车牌是否为空
    BOOL isError = [self shakeIfNeededAtRow:1 filter:nil];
    if (isError) {
        return;
    }
    //购车价格
    isError = [self shakeIfNeededAtRow:2 filter:^BOOL(NSString *text) {
        return [text floatValue] == 0;
    }];
    if (isError) {
        return;
    }
    
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        HKMyCar *car = self.selectedCar;
        GetInsuranceCalculatorOp * op = [GetInsuranceCalculatorOp operation];
        op.req_city = self.city;
        op.req_licencenumber = self.noPlateNumber ? nil : self.plateNumber;
        op.req_registered = self.noPlateNumber ? 2 : 1;
        op.req_purchaseprice = self.price;
        op.req_purchasedate = self.carryTime;
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"正在查询..."];
        }] subscribeNext:^(GetInsuranceCalculatorOp *rspOp) {
            
            @strongify(self);
            EnquiryResultVC *vc = [UIStoryboard vcWithId:@"EnquiryResultVC" inStoryboard:@"Insurance"];
            HKMyCar *curCar = [self carShouldUpdatedWithOp:rspOp];
            if (curCar) {
                vc.shouldUpdateCar = YES;
                vc.car = curCar;
            }
            else {
                vc.shouldUpdateCar = NO;
                vc.car = car;
            }
            [self.navigationController pushViewController:vc animated:YES];
            [vc reloadWithInsurance:rspOp.rsp_insuraceArray calculatorID:rspOp.rsp_calculatorID];
            [gToast dismiss];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 8;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (self.shouldHideHeaderView) {
            return CGFLOAT_MIN;
        }
        NSInteger rowNumber = ceil(self.carList.count / 2.0);
        return MAX(72, rowNumber*(35+10)+4 + 32);
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self headerCellAtIndexPath:indexPath];
    }
    NSString *cellID = [NSString stringWithFormat:@"Cell%d", (int)indexPath.row+1];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.row == 0) {
        [self setupCityCell:cell];
    }
    else if (indexPath.row == 1) {
        [self setupPlateNumberCell:cell];
    }
    else if (indexPath.row == 2) {
        [self setupPriceCell:cell];
    }
    else if (indexPath.row == 3) {
        [self setupCarryTimeCell:cell];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        JTTableViewCell *jtcell = (JTTableViewCell *)cell;
        jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
        [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //修改提车时间
    if (indexPath.row == 3) {
        [MobClick event:@"rp115-6"];
        [self.view endEditing:YES];
        [self pickDate];
    }
    else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
        if ([field isKindOfClass:[UITextField class]] && field.userInteractionEnabled == YES) {
            [field becomeFirstResponder];
        }
    }
}

#pragma mark - TableCell
- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UIView *bgView = [cell.contentView viewWithTag:1000];
    UIView *containerView = [cell.contentView viewWithTag:1001];
    bgView.clipsToBounds = YES;
    bgView.layer.masksToBounds = YES;
    [containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //正在加载
    [[RACObserve(self, isLoadingCars) takeUntilForCell:cell] subscribeNext:^(NSNumber *x) {
        if ([x boolValue]) {
            [containerView startActivityAnimationWithType:UIActivityIndicatorType];
        }
        else {
            [containerView stopActivityAnimation];
        }
    }];
    
    //加载失败
    @weakify(self);
    [[RACObserve(self, isLoadingCarsFail) takeUntilForCell:cell] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            @weakify(self);
            [containerView showIndicatorTextWith:@"获取我的爱车失败，点击重试" clickBlock:^(UIButton *sender) {
                 @strongify(self);
                 [self reloadCarList];
             }];
        }
        else {
            [containerView hideIndicatorText];
        }
    }];

    [[RACObserve(self, carList) takeUntilForCell:cell] subscribeNext:^(NSArray *cars) {
        @strongify(self);
        if (cars.count > 0) {
            [self addPlateNumberButtonsWithCarList:cars toContainerView:containerView];
        }
    }];
    return cell;
}

- (void)setupCityCell:(UITableViewCell *)cell
{
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    field.delegate = self;
    field.customTag = 0;
    field.text = self.city;
    @weakify(self);
    [[[field rac_textSignal] distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.city = x;
    }];
}

- (void)setupPriceCell:(UITableViewCell *)cell
{
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    field.text = self.price;
    field.customTag = 2;
    if (!field.delegate) {
        field.delegate = self;
    }
    @weakify(self);
    [[RACObserve(self, price) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        field.text = x;
    }];
    
    //text did changed
    [[field rac_textSignal] subscribeNext:^(NSString *text) {
        
        @strongify(self);
        if (text.length > 0) {
            self->_price = [NSString stringWithFormat:@"%.2f", [text floatValue]];
        }
    }];
}

- (void)setupPlateNumberCell:(UITableViewCell *)cell
{
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:1003];

    field.delegate = self;
    field.customTag = 1;
    @weakify(self);
    [self.carPicker addItem:button forGroupName:@"car" withChangedBlock:^(UIButton *item, BOOL selected) {
        
        @strongify(self);
        item.selected = selected;
        self.noPlateNumber = selected;
        field.userInteractionEnabled = !selected;
        if (selected) {
            field.text = @"新车未上牌";
        }
        else {
            field.text = self.plateNumber;
        }
    }];
    
    [[[button rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(UIButton *btn) {

         [MobClick event:@"rp115-4"];
         @strongify(self);
         id item = btn;
         //当取消选择新车未上牌时，先判断一下上次选择的汽车车牌是否和填写的车牌一致
         //若果一致则重新选择上次选择过的汽车车牌，否则就什么都不选
         if (btn.selected) {
             item = [self.selectedCar.licencenumber equalByCaseInsensitive:self.plateNumber] ? self.selectedCar : nil;
         }
         [self.carPicker selectItem:item forGroupName:@"car"];
    }];
    
    [[RACObserve(self, plateNumber) takeUntilForCell:cell] subscribeNext:^(id x) {
        
        @strongify(self);
        if (!self.noPlateNumber) {
            field.text = x;
        }
    }];
    
    [[[[field rac_newTextChannel] distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        self->_plateNumber = [x uppercaseString];
        [self.carPicker selectItem:nil forGroupName:@"car"];
    }];
}

- (void)setupCarryTimeCell:(UITableViewCell *)cell
{
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    field.customTag = 3;
    [[RACObserve(self, carryTime) takeUntilForCell:cell] subscribeNext:^(NSDate *time) {
        field.text = time ? [time dateFormatForYYMM] : nil;
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.customTag == 0) {
        [MobClick event:@"rp115-2"];
    }
    else if (textField.customTag == 1) {
        [MobClick event:@"rp115-3"];
    }
    else if (textField.customTag == 2) {
        [MobClick event:@"rp115-5"];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //车牌
    if (textField.customTag == 1) {
        textField.text = [textField.text uppercaseString];
    }
    //价格
    if (textField.customTag == 2){
        textField.text  = self.price;
    }
}

#pragma mark - Private
- (void)addPlateNumberButtonsWithCarList:(NSArray *)carList toContainerView:(UIView *)containerView
{
    CGFloat spacing = floor((self.view.frame.size.width - 140*2)/3.2);
    UIButton *current;
    for (int i = 0; i < carList.count; i++) {
        HKMyCar *car = carList[i];
        current = [self createButtonWithCar:car index:i];
        [containerView addSubview:current];
        id prev = [containerView viewWithTag:2001+i-1];
        //左边的车牌
        if (i % 2 == 0) {
            prev = prev ? [(UIView *)prev mas_bottom] : containerView.mas_top;
            [current mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(containerView.mas_left).offset(spacing);
                make.top.equalTo(prev).offset(10);
            }];
        }
        //右边的车牌
        else {
            [current mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(containerView.mas_right).offset(-spacing);
                make.top.equalTo([(UIView *)prev mas_top]).offset(0);
            }];
        }
    }
}

- (UIButton *)createButtonWithCar:(HKMyCar *)car index:(NSInteger)index
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    btn.tag = 2001+index;
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:car.licencenumber forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -14, 0, 0)];
    UIImage *bgImg = [[UIImage imageNamed:@"mec_btn_bg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [btn setBackgroundImage:bgImg forState:UIControlStateNormal];
    BOOL selected = [car.customInfo[@"selected"] boolValue];
    [btn setImage:[UIImage imageNamed:selected ? @"ins_box3" : @"ins_box2"] forState:UIControlStateNormal];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(140, 35));
    }];
    btn.customObject = car;
    car.customInfo[@"btn"] = btn;

    @weakify(self);
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
        [MobClick event:@"rp115-1"];
        
        @strongify(self)
        [self.carPicker selectItem:x.customObject];
        [self.view endEditing:YES];
    }];
    return btn;
}

- (void)setPlateNumberButton:(UIButton *)btn selected:(BOOL)selected forCar:(HKMyCar *)car
{
    BOOL oldSelected = [car.customInfo[@"selected"] boolValue];
    if (oldSelected != selected) {
        car.customInfo[@"selected"] = @(selected);
        [btn setImage:[UIImage imageNamed:selected ? @"ins_box3" : @"ins_box2"] forState:UIControlStateNormal];
    }
}

- (void)shakeAndScrollToCellAtRow:(NSInteger)row message:(NSString *)msg
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    [cell.contentView shake];
    [gToast showText:msg];
}

- (BOOL)shakeIfNeededAtRow:(NSInteger)row filter:(BOOL(^)(NSString *text))filter
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    BOOL shouldShake = field.text.length == 0;
    if (filter) {
        shouldShake = filter(field.text);
    }
    if (shouldShake) {
        [cell.contentView shake];
        return YES;
    }
    return NO;
}

- (void)pickDate
{
    [[self.datePickerVC rac_presentPickerVCInView:self.navigationController.view withSelectedDate:self.carryTime]
     subscribeNext:^(NSDate *date) {
        self.carryTime = date;
    }];
}

- (UIView *)emptyHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//返回一个需要更新的车辆信息，如果车牌信息不存在或信息没有变动则为空
- (HKMyCar *)carShouldUpdatedWithOp:(GetInsuranceCalculatorOp *)op
{
    //如果没有填写车牌号码，不更新车辆
    if (self.noPlateNumber) {
        return nil;
    }
    HKMyCar *car = self.selectedCar;
    //如果车牌号存在，则判断是否更新车辆
    if ([op.req_licencenumber equalByCaseInsensitive:car.licencenumber]) {
        HKMyCar *curCar = [car copy];
        BOOL shouldUpdate = NO;
        if (op.req_purchasedate && ![op.req_purchasedate isEqualToDate:car.purchasedate]) {
            shouldUpdate = YES;
            curCar.purchasedate = op.req_purchasedate;
        }
        if (![op.req_purchaseprice equalByCaseInsensitive:[NSString stringWithFormat:@"%.2f", car.price]]) {
            shouldUpdate = YES;
            curCar.price = [op.req_purchaseprice floatValue];
        }
        if (shouldUpdate) {
            return curCar;
        }
    }
    //如果车牌号不存在，则判断是否添加车辆
    else {
        HKMyCar *curCar = [HKMyCar new];
        curCar.licencenumber = op.req_licencenumber;
        curCar.price = [op.req_purchaseprice floatValue];
        curCar.purchasedate = op.req_purchasedate;
        return curCar;
    }
    return nil;
}
@end
