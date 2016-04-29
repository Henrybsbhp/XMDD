//
//  ValuationHomeVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/4/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ValuationHomeVC.h"
#import "AreaTablePickerVC.h"
#import "MyCarStore.h"
#import "ADViewController.h"
#import "EditCarVC.h"
#import "CarEvaluateOp.h"
#import "ValuationResultVC.h"
#import "HistoryCollectionVC.h"
#import "CommitSuccessVC.h"
#import "HKPageSliderView.h"
#import "ValuationEmptySubView.h"
#import "ValuationCarSubView.h"


@interface ValuationHomeVC ()<UIScrollViewDelegate, UITextFieldDelegate,PageSliderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;

@property (nonatomic,strong) HKMyCar * selectCar;
@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic,strong) NSArray * dataSource;

@property (nonatomic, strong) NSNumber * cityId;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) HKLocationDataModel * locationData;
@property (nonatomic, assign) LocateState locateState;
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) HKPageSliderView * sliderView;

@end


@implementation ValuationHomeVC

- (void)dealloc {
    DebugLog(@"ValuationHomeVC dealloc~~~");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
}

#pragma mark - Setup
- (void)setupAdView
{
    CKAsyncMainQueue(^{
        /**
         *  点击广告事件（只需传入底层事件，具体点了哪个广告在底层实现）
         */
        self.advc  =[ADViewController vcWithADType:AdvertisementValuation boundsWidth:self.view.bounds.size.width
                                          targetVC:self mobBaseEvent:@"rp601_5" mobBaseEventDict:nil];
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
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate and datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count == 0 ? 2 :4;
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
        //定位
        return 40;
    }
    else if (indexPath.row == 1) {
        //内容
        return 220;
    }
    else if (indexPath.row == 2) {
        //修改的tip
        return 35;
    }
    //估值按钮
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self locationCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 1) {
        cell = [self contentCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 2) {
        cell = [self promptCellAtIndexPath:indexPath];
    }
    else {
        cell = [self bottomBtnCellAtIndexPath:indexPath];
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
            [activityView stopAnimating];
            locationL.text = [NSString stringWithFormat:@"%@/%@", self.locationData.province, self.locationData.city];
        }
        else {
            if (!self.isSelected) {
                locImageV.hidden = NO;
                [activityView stopAnimating];
                locationL.text = @"定位失败，请选择";
            }
        }
    }];
    return cell;
}

- (UITableViewCell *)contentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContentCell" forIndexPath:indexPath];
    UIView *view = [cell.contentView viewWithTag:1001];
    
    @weakify(self);
    if (self.dataSource.count == 0) {
        ValuationEmptySubView * emptySubVC = [[ValuationEmptySubView alloc] init];
        [self addChildViewController:emptySubVC];
        emptySubVC.view.frame = view.bounds;
        [view addSubview:emptySubVC.view];
        [emptySubVC setAddCarClickBlock:^{
            [MobClick event:@"rp601_3"];
            @strongify(self);
            if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
                self.carIndex = self.dataSource.count;
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
    else {
        NSMutableArray *titleArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < self.dataSource.count; i++) {
            HKMyCar *car = self.dataSource[i];
            [titleArray addObject:car.licencenumber];
        }
        NSInteger count;
        if (self.dataSource.count >= 5) {
            count = self.dataSource.count;
        }
        else {
            count = self.dataSource.count + 1;
            [titleArray addObject:@"添加爱车"];
        }
        
        HKPageSliderView *pageSliderView = [[HKPageSliderView alloc] initWithFrame:view.bounds andTitleArray:titleArray andStyle:HKTabBarStyleCleanMenu atIndex:self.carIndex];
        pageSliderView.contentScrollView.delegate = self;
        pageSliderView.delegate = self;
        if (view.subviews.count != 0) {
            [view removeSubviews];
        }
        [view addSubview:pageSliderView];
        self.sliderView = pageSliderView;//赋值全局
        [self observeScrollViewOffset];
        [self addContentView:count];
    }
    
    return cell;
}

-(void)addContentView:(NSInteger)count
{
    for (int i = 0; i < count; i ++) {
        if (self.dataSource.count > i) {
            HKMyCar *car = [self.dataSource safetyObjectAtIndex:i];
            
            ValuationCarSubView * contentVC = [[ValuationCarSubView alloc] init];
            [self addChildViewController:contentVC];
            contentVC.car = car;
            contentVC.view.frame = CGRectMake(i * self.view.bounds.size.width, 0, self.view.bounds.size.width, 150);

            @weakify(contentVC);
            @weakify(self);
            [contentVC setContentDidChangeBlock:^() {
                [MobClick event:@"rp601_7"];
                @strongify(contentVC);
                @strongify(self);
                self.selectCar = contentVC.car;
            }];
            
            [self.sliderView.contentScrollView addSubview:contentVC.view];
        }
        else {
            ValuationEmptySubView * emptySubVC = [[ValuationEmptySubView alloc] init];
            [self addChildViewController:emptySubVC];
            emptySubVC.view.frame = CGRectMake(i * self.view.bounds.size.width, 0, self.view.bounds.size.width, 150);
            [self.sliderView.contentScrollView addSubview:emptySubVC.view];
            @weakify(self);
            [emptySubVC setAddCarClickBlock:^{
                [MobClick event:@"rp601_3"];
                @strongify(self);
                if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
                    self.carIndex = self.dataSource.count;
                    EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }
    }
}

- (UITableViewCell *)promptCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PromptCell" forIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)bottomBtnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BottomBtnCell" forIndexPath:indexPath];
    UIButton *valuationButton = [cell.contentView viewWithTag:1001];
    @weakify(self);
    [[[valuationButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self evaluationAction];
    }];
    
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
            self.isSelected = YES;
            self.locationData.province = provinceModel.infoName;
            self.locationData.city = cityModel.infoName;
            self.locationLabel.text = [NSString stringWithFormat:@"%@/%@", provinceModel.infoName, cityModel.infoName];
            self.cityId = [NSNumber numberWithInteger:cityModel.infoId];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView endEditing:YES];
    if (scrollView == self.sliderView.contentScrollView) {
        NSInteger pageIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5); //过半取整
        [self.sliderView selectAtIndex:pageIndex];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.sliderView.contentScrollView) {
        HKMyCar *car = [self.dataSource safetyObjectAtIndex:self.sliderView.currentIndex];
        self.selectCar = car;
        self.carIndex = self.sliderView.currentIndex;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.sliderView.contentScrollView) {
        HKMyCar *car = [self.dataSource safetyObjectAtIndex:self.sliderView.currentIndex];
        self.selectCar = car;
        self.carIndex = self.sliderView.currentIndex;
    }
}

#pragma mark - Utility

- (void)evaluationAction {
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
    
    CGFloat miles = [[NSString formatForPrice:self.selectCar.odo / 10000.00] floatValue];
    if (miles == 0) {
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
    op.req_mile = miles;
    op.req_modelid = self.selectCar.detailModel.modelid;
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
        vc.modelStr = self.selectCar.detailModel.modelname;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}


- (IBAction)goToHistoryVC:(id)sender {
    [MobClick event:@"rp601_1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        HistoryCollectionVC *historyVC=[UIStoryboard vcWithId:@"HistoryCollectionVC" inStoryboard:@"Valuation"];
        [self.navigationController pushViewController:historyVC animated:YES];
    }
}

#pragma mark - PageSliderDelegate
//- (void)pageClickAtIndex:(NSInteger)index
//{
//    self.currentIndex = index;
//    [self loadPageIndex:index animated:YES];
//}

#pragma mark - PageSliderDelegate
- (BOOL)observeScrollViewOffset
{
    @weakify(self)
    [RACObserve(self.sliderView.contentScrollView,contentOffset) subscribeNext:^(NSValue * value) {
        
        @strongify(self)
        CGPoint p = [value CGPointValue];
        [self.sliderView slideOffsetX:p.x andTotleW:self.sliderView.contentScrollView.contentSize.width andPageW:gAppMgr.deviceInfo.screenSize.width];
    }];
    
    return YES;
}

@end
