//
//  ValuationViewController.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "ValuationViewController.h"
#import "AreaTablePickerVC.h"
#import <JT3DScrollView.h>
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
#import <IQKeyboardManager/KeyboardManager.h>
#import "ValuationResultVC.h"

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
            [self.carStore sendEvent:[self.carStore getAllCars]];
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
        //测试有广告的情况
        self.advc  =[ADViewController vcWithADType:AdvertisementHomePage boundsWidth:self.view.bounds.size.width
                                          targetVC:self mobBaseEvent:@"rp314-1"];
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
        self.locateState = LocateStateFailure;
        [gToast showError:@"获取城市信息失败"];
    }];
}

- (void)setupCarStore
{
    @weakify(self);
    self.carStore = [MyCarStore fetchOrCreateStore];
    [self.carStore subscribeEventsWithTarget:self receiver:^(HKStore *store, HKStoreEvent *evt) {
        @strongify(self);
        [self reloadDataWithEvent:evt];
    }];
}

- (void)reloadDataWithEvent:(HKStoreEvent *)evt
{
    @weakify(self);
    [[[[evt.signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        @strongify(self);
        self.tableView.hidden = YES;
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.dataSource = [self.carStore.cache allObjects];
        self.selectCar = [[HKMyCar alloc] init];
        self.selectCar = [self.dataSource safetyObjectAtIndex:0];
        self.miles = self.selectCar.odo;
        self.modelId = self.selectCar.detailModel.modelid;
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
        
        //车系选择
        HKSubscriptInputField * modelField = [view viewWithTag:202];
        modelField.inputField.userInteractionEnabled = NO;
        
        [view setSelectTypeClickBlock:^{
            PickAutomobileBrandVC *vc = [UIStoryboard vcWithId:@"PickerAutomobileBrandVC" inStoryboard:@"Car"];
            vc.originVC = self;
            [vc setCompleted:^(AutoBrandModel *brand, AutoSeriesModel * series, AutoDetailModel * model) {
                self.selectCar.brand = brand.brandname;
                self.selectCar.seriesModel = series;
                self.selectCar.detailModel = model;
                modelField.inputField.text = [NSString stringWithFormat:@"%@ %@ %@", brand.brandname, series.seriesname, model.modelname];
                self.modelId = model.modelid;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
        //日期选择
        HKSubscriptInputField * dateField = [view viewWithTag:203];
        dateField.inputField.userInteractionEnabled = NO;
        [view setSelectDateClickBlock:^{
            HKMyCar * myCar = [self.dataSource safetyObjectAtIndex:i];
            self.datePicker.maximumDate = [NSDate date];
            NSDate *selectedDate = myCar.purchasedate ? myCar.purchasedate : [NSDate date];
            
            [[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:selectedDate]
             subscribeNext:^(NSDate *date) {
                 dateField.inputField.text = [date dateFormatForYYMM];
                 self.selectCar.purchasedate = date;
             }];
        }];
        
        [view setAddCarClickBlock:^{
            if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
    
    scrollView.contentSize = CGSizeMake(count * w, self.cardHeight);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        AreaTablePickerVC * vc = [AreaTablePickerVC initPickerAreaVCWithType:PickerVCTypeProvinceAndCity fromVC:self];
        
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * districtModel) {
            self.locationLabel.text = [NSString stringWithFormat:@"%@/%@", provinceModel.infoName, cityModel.infoName];
            self.cityId = [NSNumber numberWithInteger:cityModel.infoId];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView endEditing:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    JT3DScrollView * jt3Dscroll = (JT3DScrollView *)scrollView;
    self.selectCar = [self.dataSource safetyObjectAtIndex:jt3Dscroll.currentPage];
    self.miles = self.selectCar.odo;
    self.modelId = self.selectCar.detailModel.modelid;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.advc.adList.count != 0) {
        self.tableView.contentSize=CGSizeMake(CGRectGetWidth(self.tableView.contentFrame), CGRectGetHeight(self.tableView.contentFrame) + 170);
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self.tableView setContentOffset:CGPointMake(0, 170)];
                         }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.miles = [textField.text floatValue];
    
    if (self.advc.adList.count != 0) {
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.tableView setContentOffset:CGPointMake(0, 0)];
        } completion:^(BOOL finished) {
            
            self.tableView.contentSize=CGSizeMake(CGRectGetWidth(self.tableView.contentFrame), CGRectGetHeight(self.tableView.contentFrame) - 170);
        }];
    }
}

- (IBAction)recordAction:(id)sender {
    
}

- (IBAction)evaluationAction:(id)sender {
    
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
    
    if (!self.selectCar.detailModel.modelname) {
        [gToast showText:@"请选择具体车型"];
        return;
    }
    
    CarEvaluateOp * op = [CarEvaluateOp operation];
    op.req_mile = self.miles;
    op.req_modelid = @24712;
    op.req_buydate = self.selectCar.purchasedate;
    op.req_carid = self.selectCar.carId;
    op.req_cityid = self.cityId;
    op.req_licenseno = self.selectCar.licencenumber;
    
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"估值中..."];
    }] subscribeNext:^(CarEvaluateOp * op) {
        
        [gToast dismiss];
        ValuationResultVC * vc = [valuationStoryboard instantiateViewControllerWithIdentifier:@"ValuationResultVC"];
        vc.evaluateOp = op;
        vc.logoUrl = self.selectCar.brandLogo;
        vc.cityStr = self.locationLabel.text;
        vc.carId = self.selectCar.carId;
        vc.cityId = self.cityId;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
