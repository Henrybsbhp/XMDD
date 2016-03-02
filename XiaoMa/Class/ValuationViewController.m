//
//  ValuationViewController.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "ValuationViewController.h"
#import "AreaTablePickerVC.h"
#import "JT3DScrollView.h"
#import "CarValuationSubView.h"
#import "HKSubscriptInputField.h"
#import "MyCarStore.h"
#import "DatePickerVC.h"
#import "NSDate+DateForText.h"
#import "ADViewController.h"
#import "CarScrollTableViewCell.h"
#import "AreaTablePickerVC.h"
#import "EditCarVC.h"
#import "PickAutomobileBrandVC.h"
#import "CarEvaluateOp.h"
#import "IQKeyboardManager.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "ValuationResultVC.h"
#import "HistoryCollectionVC.h"
#import "CommitSuccessVC.h"
#define ScreenHeight    [[UIScreen mainScreen] bounds].size.height

@interface ValuationViewController ()<UIScrollViewDelegate, UITextFieldDelegate>

@property (nonatomic)CGFloat cardSpacing;
@property (nonatomic)CGFloat cardHeight;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;

@property (nonatomic,strong)HKMyCar * selectCar;
@property (nonatomic, strong)MyCarStore *carStore;
@property (nonatomic,strong)NSArray * dataSource;

@property (nonatomic, strong)UILabel * locationLabel;
@property (nonatomic, strong)DatePickerVC *datePicker;
@property (nonatomic, strong)HKLocationDataModel * locationData;
@property (nonatomic, assign)LocateState locateState;

@property (nonatomic, assign)CGFloat miles;
@property (nonatomic, strong)NSNumber * modelId;
@property (nonatomic, strong)NSDate * buyDate;
@property (nonatomic, strong)NSNumber * carId;
@property (nonatomic, strong)NSNumber * cityId;
@property (nonatomic, strong)NSString * modelStr;

@end

@implementation ValuationViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
    
    [self setSpacingByScreen];
    [self setupAdView];
    [self requestLocation];
    [self setupCarStore];
    
    //监听用户登录
    @weakify(self);
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(JTUser *user) {
        
        @strongify(self);
        if (gAppMgr.myUser.userID) {
            [[self.carStore getAllCars] send];
        }
    }];
}

- (void)setSpacingByScreen
{
    if (ScreenHeight == 480) {
        self.cardSpacing = 5;
        self.cardHeight = 225;
    }
    else if (ScreenHeight > 667) {
        self.cardSpacing = 60;
        self.cardHeight = 315;
    }
    else if (ScreenHeight == 568){
        self.cardSpacing = 20;
        self.cardHeight = 280;
    }
    else {
        self.cardSpacing = 40;
        self.cardHeight = 280;
    }
}

- (void)setupAdView
{
    CKAsyncMainQueue(^{
        /**
         *  点击广告事件（只需传入底层事件，具体点了哪个广告在底层实现）
         */
        self.advc  =[ADViewController vcWithADType:AdvertisementValuation boundsWidth:self.view.bounds.size.width
                                          targetVC:self mobBaseEvent:@"rp601_5"];
        [self.advc reloadDataForTableView:self.tableView];
    });
}

#pragma mark - 获取定位信息
- (void)requestLocation
{
    self.locationData = [[HKLocationDataModel alloc] init];
    self.locateState = LocateStateLocating;
    @weakify(self);
    [[[gMapHelper rac_getInvertGeoInfo] flattenMap:^RACStream *(id value) {
        @strongify(self);
        self.locationData.province = gMapHelper.addrComponent.province;
        self.locationData.city = gMapHelper.addrComponent.city;
        self.locateState = LocateStateSuccess;
        
        GetAreaByPcdOp * op = [GetAreaByPcdOp operation];
        op.req_province = gMapHelper.addrComponent.province;
        op.req_city = gMapHelper.addrComponent.city;
        return [op rac_postRequest];
    }] subscribeNext:^(GetAreaByPcdOp * op) {
        
        @strongify(self);
        self.cityId = [NSNumber numberWithInteger:op.rsp_city.infoId];
        
    } error:^(NSError *error) {
        @strongify(self);
        self.locateState = LocateStateFailure;
        [gToast showError:@"获取城市信息失败"];
    }];
}

- (void)setupCarStore
{
    @weakify(self);
    self.carStore = [MyCarStore fetchOrCreateStore];
    [self.carStore subscribeWithTarget:self domain:@"cars" receiver:^(CKStore *store, CKEvent *evt) {

        @strongify(self);
        [self reloadDataWithEvent:evt];
    }];
}

- (void)reloadDataWithEvent:(CKEvent *)evt
{
    CKEvent *event = evt;
    @weakify(self);
    [[[[evt.signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        @strongify(self);
        self.tableView.hidden = YES;
        self.view.indicatorPoistionY = floor((self.view.frame.size.height - 75)/2.0);
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.dataSource = [self.carStore.cars allObjects];
        self.selectCar = [[HKMyCar alloc] init];
        if ([event isEqualForName:@"addCar"] && event.object){
            self.selectCar = [self.carStore.cars objectForKey:event.object];
        }
        else {
            self.selectCar = [self.dataSource safetyObjectAtIndex:self.carIndex];
        }
        NSString * milesStr = [NSString formatForPrice:self.selectCar.odo / 10000.00];
        self.miles = [milesStr floatValue];
        self.modelId = self.selectCar.detailModel.modelid;
        self.modelStr = self.selectCar.detailModel.modelname;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate and datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 40;
    }
    return self.cardSpacing + self.cardHeight + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self locationCellAtIndexPath:indexPath];
    }
    else {
        cell = [self contentCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)locationCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    UIImageView * locImageV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel * locationL = (UILabel *)[cell.contentView viewWithTag:1002];
    UIActivityIndicatorView * activityView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1003];
    
    self.locationLabel = locationL;
    @weakify(self);
    [[[RACObserve(self, locateState) distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        if (self.locateState == LocateStateLocating) {
            locImageV.hidden = YES;
            locationL.text = @"定位中...";
            [activityView startAnimating];
        }
        else if (self.locateState == LocateStateSuccess) {
            locImageV.hidden = NO;
            locImageV.image = [UIImage imageNamed:@"val_location_green"];
            [activityView stopAnimating];
            locationL.text = [NSString stringWithFormat:@"%@/%@", self.locationData.province, self.locationData.city];
        }
        else {
            locImageV.hidden = NO;
            locImageV.image = [UIImage imageNamed:@"val_location_gray"];
            [activityView stopAnimating];
            locationL.text = @"定位失败，请选择";
        }
    }];
    return cell;
}

- (UITableViewCell *)contentCellAtIndexPath:(NSIndexPath *)indexPath
{
    CarScrollTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContentCell" forIndexPath:indexPath];
    
    //修改爱车卡片的约束
    cell.topConstraint.constant = self.cardSpacing;
    
    JT3DScrollView *scrollView = (JT3DScrollView *)[cell.contentView viewWithTag:1001];
    scrollView.effect = JT3DScrollViewEffectDepth;
    scrollView.angleRatio = 0.3;
    scrollView.translateX = 0.03;
    scrollView.translateY = 0.05;
    scrollView.delegate = self;
    
    CGFloat w = CGRectGetWidth(self.tableView.frame) - 40;
    NSInteger count;
    if (self.dataSource.count >= 5) {
        count = 5;
    }
    else {
        count = self.dataSource.count + 1;
    }
    for (int i = 0; i <count; i++) {
        
        CarValuationSubView *view = [[CarValuationSubView alloc] initWithFrame:CGRectMake(w * i, 0, w, self.cardHeight) andCarModel:[self.dataSource safetyObjectAtIndex:i]];
        [scrollView addSubview:view];
        
        HKSubscriptInputField * milesField = [view viewWithTag:201];
        milesField.inputField.delegate = self;
        [milesField.inputField addDoneOnKeyboardWithTarget:self action:@selector(finishInputAction) shouldShowPlaceholder:YES];
        
        //车系选择
        HKSubscriptInputField * modelField = [view viewWithTag:202];
        modelField.inputField.userInteractionEnabled = NO;
        @weakify(self);
        [view setSelectTypeClickBlock:^{
            [MobClick event:@"rp601_7"];
            @strongify(self);
            PickAutomobileBrandVC *vc = [UIStoryboard vcWithId:@"PickerAutomobileBrandVC" inStoryboard:@"Car"];
            vc.originVC = self;
            [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel * series, AutoDetailModel * model) {
                @strongify(self);
                self.selectCar.brand = brand.brandname;
                self.selectCar.brandLogo = brand.brandLogo;
                self.selectCar.seriesModel = series;
                self.selectCar.detailModel = model;
                modelField.inputField.text = [NSString stringWithFormat:@"%@", model.modelname];
                self.modelId = model.modelid;
                self.modelStr = model.modelname;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
        //日期选择
        HKSubscriptInputField * dateField = [view viewWithTag:203];
        dateField.inputField.userInteractionEnabled = NO;
        [view setSelectDateClickBlock:^{
            [MobClick event:@"rp601_8"];
            @strongify(self);
            HKMyCar * myCar = [self.dataSource safetyObjectAtIndex:i];
            self.datePicker.maximumDate = [NSDate date];
            NSDate *selectedDate = myCar.purchasedate ? myCar.purchasedate : [NSDate date];
            
            [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:selectedDate]
             subscribeNext:^(NSDate *date) {
                 @strongify(self);
                 dateField.inputField.text = [date dateFormatForYYMM];
                 self.selectCar.purchasedate = date;
             }];
        }];
        
        [view setAddCarClickBlock:^{
            @strongify(self);
            /**
             *  添加评估车辆
             */
            [MobClick event:@"rp601_3"];
            if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
                self.carIndex = self.dataSource.count;
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
    
    scrollView.contentSize = CGSizeMake(count * w, self.cardHeight);
    
    [scrollView loadPageIndex:self.carIndex animated:NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        /**
         *  定位事件
         */
        [MobClick event:@"rp601_2"];
        AreaTablePickerVC * vc = [AreaTablePickerVC initPickerAreaVCWithType:PickerVCTypeProvinceAndCity fromVC:self];
        @weakify(self);
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * districtModel) {
            @strongify(self);
            self.locationData.province = provinceModel.infoName;
            self.locationData.city = cityModel.infoName;
            self.locationLabel.text = [NSString stringWithFormat:@"%@/%@", provinceModel.infoName, cityModel.infoName];
            self.cityId = [NSNumber numberWithInteger:cityModel.infoId];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)finishInputAction
{
    [self.view endEditing:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView endEditing:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    JT3DScrollView * jt3Dscroll = (JT3DScrollView *)scrollView;
    self.selectCar = [self.dataSource safetyObjectAtIndex:jt3Dscroll.currentPage];
    NSString * milesStr = [NSString formatForPrice:self.selectCar.odo / 10000.00];
    self.miles = [milesStr floatValue];
    self.modelId = self.selectCar.detailModel.modelid;
    self.modelStr = self.selectCar.detailModel.modelname;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [MobClick event:@"rp601_6"];
    if (self.advc.adList.count != 0) {
        self.tableView.contentSize=CGSizeMake(CGRectGetWidth(self.tableView.contentFrame), CGRectGetHeight(self.tableView.contentFrame) + 170);
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self.tableView setContentOffset:CGPointMake(0, 170)];
                         }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text.length > 7) {
        textField.text = @"";
        [gToast showText:@"请输入正确的行驶里程"];
    }
    else {
        textField.text = [NSString formatForPrice:[textField.text floatValue]];
        self.miles = [textField.text floatValue];
        self.selectCar.odo = self.miles * 10000;
    }
    
    if (self.advc.adList.count != 0) {
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.tableView setContentOffset:CGPointMake(0, 0)];
        } completion:^(BOOL finished) {
            
            self.tableView.contentSize=CGSizeMake(CGRectGetWidth(self.tableView.contentFrame), CGRectGetHeight(self.tableView.contentFrame) - 170);
        }];
    }
}

- (IBAction)evaluationAction:(id)sender {
    /**
     *  估值事件
     */
    [MobClick event:@"rp601_4"];
    [self.view endEditing:YES];
    
    if (![self.selectCar isKindOfClass:[HKMyCar class]]) {
        [gToast showText:@"请添加爱车"];
        return;
    }
    
    if (!self.cityId) {
        [gToast showText:@"请选择城市后进行估值"];
        return;
    }
    
    if (self.miles == 0) {
        [gToast showText:@"请填写正确的行驶里程"];
        return;
    }
    
    if (![self.selectCar.detailModel.modelid integerValue]) {
        [gToast showText:@"请选择具体车型"];
        return;
    }
    
    if (!self.selectCar.purchasedate) {
        [gToast showText:@"请选择购车时间"];
        return;
    }
    CarEvaluateOp * op = [CarEvaluateOp operation];
    op.req_mile = self.miles;
    op.req_modelid = self.modelId;
    op.req_buydate = self.selectCar.purchasedate;
    op.req_carid = self.selectCar.carId;
    op.req_cityid = self.cityId;
    op.req_licenseno = self.selectCar.licencenumber;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"估值中..."];
    }] subscribeNext:^(CarEvaluateOp * op) {
        
        @strongify(self);
        [gToast dismiss];
        [[self.carStore getAllCars] send];
        ValuationResultVC * vc = [valuationStoryboard instantiateViewControllerWithIdentifier:@"ValuationResultVC"];
        vc.evaluateOp = op;
        vc.logoUrl = self.selectCar.brandLogo;
        vc.carId = self.selectCar.carId;
        vc.provinceName = self.locationData.province;
        vc.cityName = self.locationData.city;
        vc.modelStr = self.modelStr;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

- (void)dealloc {
    DebugLog(@"ValuationViewController dealloc~~~");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goToHistoryVC:(id)sender {
    /**
     *  历史记录事件
     */
    [MobClick event:@"rp601_1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        HistoryCollectionVC *historyVC=[UIStoryboard vcWithId:@"HistoryCollectionVC" inStoryboard:@"Valuation"];
        [self.navigationController pushViewController:historyVC animated:YES];
    }
}

@end
