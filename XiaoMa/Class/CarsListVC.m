//
//  CarsListVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CarsListVC.h"
#import "XiaoMa.h"
#import "EditCarVC.h"
#import "CarListSubView.h"
#import "UIView+JTLoadingView.h"
#import "MyCarStore.h"
#import "NSString+Format.h"
#import "HKImageAlertVC.h"
#import "HKPageSliderView.h"
#import "CarListSubVC.h"

#import "ValuationViewController.h"

@interface CarsListVC ()<UIScrollViewDelegate, PageSliderDelegate>

@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) HKPageSliderView * sliderView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backAction:(id)sender;

@end

@implementation CarsListVC

- (void)dealloc
{
    DebugLog(@"CarListVC dealloc");
}

- (void)awakeFromNib
{
    _model = [[MyCarListVModel alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupCarStore];
    [[self.carStore getAllCars] send];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCarStore
{
    self.carStore = [MyCarStore fetchOrCreateStore];
    
    @weakify(self);
    [self.carStore subscribeWithTarget:self domain:@"cars" receiver:^(CKStore *store, CKEvent *evt) {
        @strongify(self);
        [self reloadDataWithEvent:evt];
    }];
}

- (void)setOriginCarID:(NSNumber *)originCarID
{
    _originCarID = originCarID;
    [[self.carStore getAllCarsIfNeeded] send];
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
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.datasource = [self.carStore.cars allObjects];
        HKMyCar *defCar = [self.carStore defalutCar];
        if (self.model.allowAutoChangeSelectedCar) {
            HKMyCar *car = nil;
            if (_originCarID) {
                car = [self.carStore.cars objectForKey:_originCarID];
            }
            if ([event isEqualForName:@"addCar"]) {
                car = x;
            }
            if (!car && self.model.currentCar) {
                car = [self.carStore.cars objectForKey:self.model.currentCar.carId];
            }
            if (!car) {
                car = defCar;
            }
            self.model.selectedCar = car;
            self.model.currentCar = car;
        }
        else {
            if (![defCar isEqual:self.model.selectedCar]) {
                self.model.selectedCar = defCar;
            }
            if (_originCarID) {
                self.model.currentCar = [self.carStore.cars objectForKey:_originCarID];
            }
            else if (![event isEqualForAnyoneOfNames:@[@"updateCar",@"addCar"]]) {
                self.model.currentCar = defCar;
            }
            else if ([event isEqualForName:@"addCar"]) {
                self.model.currentCar = x;
            }
            if (!self.model.currentCar) {
                self.model.currentCar = self.model.selectedCar;
            }
        }
        if (self.datasource.count >= 5) {
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
        else {
            UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(actionAddCar:)];
            [self.navigationItem setRightBarButtonItem:right animated:YES]; //解决添加按钮的抖动
        }
        if (self.datasource.count == 0) {
            [self.view showDefaultEmptyViewWithText:@"暂无爱车，快去添加一辆吧" tapBlock:^{
                @strongify(self);
                [self actionAddCar:nil];
            }];
        }
        else {
            [self refreshTableView];
        }
        _originCarID = nil;
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.view showDefaultEmptyViewWithText:@"获取爱车信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [[self.carStore getAllCars] send];
        }];
    }];
}

- (void)refreshTableView
{
    [self.view hideDefaultEmptyView];
    [self.view hideIndicatorText];
    self.tableView.hidden = NO;
    
    for (NSInteger i=0; i<self.datasource.count; i++) {
        HKMyCar *car = self.datasource[i];
        [self createCardWithCar:car atIndex:i];
    }
    
    NSInteger index = NSNotFound;
    
    if (self.model.currentCar) {
        index = [self.datasource indexOfObject:self.model.currentCar];
    }
    if (index == NSNotFound) {
        index = 0;
    }
    [self.scrollView loadPageIndex:index animated:NO];
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 150;
    }
    else if (indexPath.row == 1) {
        return 390;
    }
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self headerCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 1) {
        cell = [self carCellAtIndexPath:indexPath];
    }
    else {
        cell = [self sectionCellAtIndexPath:indexPath];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - About Cell
- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderLabel"];
    
    UILabel *stateLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *caridLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *defaultLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    
    return cell;
}

- (UITableViewCell *)carCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"CarCell" forIndexPath:indexPath];
    HKPageSliderView *sliderView= [cell.contentView viewWithTag:1001];
    
    NSMutableArray *carNumArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.datasource.count; i++) {
        HKMyCar *car = self.datasource[i];
        [carNumArray addObject:car.licencenumber];
    }
    
    if (carNumArray.count > 0) {
        HKPageSliderView *pageSliderView = [[HKPageSliderView alloc] initWithFrame:sliderView.bounds andTitleArray:carNumArray andStyle:2];
        pageSliderView.delegate = self;
        pageSliderView.contentScrollView.delegate = self;
        self.sliderView = pageSliderView;
        for (NSInteger i = 0; i < self.datasource.count; i ++) {
            [self addContentAction:i];
        }
    }
    return cell;
}

- (UITableViewCell *)sectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SectionCell" forIndexPath:indexPath];
    return cell;
}





- (void)createCardWithCar:(HKMyCar *)car atIndex:(NSInteger)index
{
    CGFloat w = CGRectGetWidth(self.scrollView.frame);
    CGFloat h = CGRectGetHeight(self.scrollView.frame);
    CGFloat x = self.scrollView.subviews.count * w;
    
    CarListSubView *view = [[CarListSubView alloc] initWithFrame:CGRectMake(x, 0, w, h)];
    [self.scrollView addSubview:view];
    self.scrollView.contentSize = CGSizeMake(x + w, h);
    
    [self reloadSubView:view withCar:car atIndex:index];
}

#pragma mark - Action
-(void)addContentAction:(NSInteger)index
{
    HKMyCar *car = self.datasource[index];
    
    CarListSubVC * contentVC = [[CarListSubVC alloc] init];
    [self addChildViewController:contentVC];
    contentVC.car = car;
    contentVC.view.frame = CGRectMake(index * self.view.bounds.size.width, 0, self.view.bounds.size.width, 300);
    [self.sliderView.contentScrollView addSubview:contentVC.view];
}


- (IBAction)backAction:(id)sender {
    //如果爱车信息不完整
    if (self.model.allowAutoChangeSelectedCar && self.model.selectedCar && ![self.model.selectedCar isCarInfoCompleted]) {
        
        HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
        alert.topTitle = @"温馨提示";
        alert.imageName = @"mins_bulb";
        alert.message = @"您的爱车信息不完整，是否现在完善？";
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"放弃" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
            [alertVC dismiss];
            if (self.model.originVC) {
                [self.navigationController popToViewController:self.model.originVC animated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        @weakify(self);
        HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"去完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            @strongify(self);
            [alertVC dismiss];
            [MobClick event:@"rp104_9"];
            EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
            vc.originCar = self.model.selectedCar;
            vc.model = self.model;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        alert.actionItems = @[cancel, improve];
        [alert show];
    }
    else {
        if (self.model.originVC) {
            [self.navigationController popToViewController:self.model.originVC animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.model.finishBlock) {
            self.model.finishBlock(self.model.selectedCar);
        }
    }
}

- (IBAction)actionAddCar:(id)sender
{
    [MobClick event:@"rp309_1"];
    EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Reload
- (void)reloadSubView:(CarListSubView *)subv withCar:(HKMyCar *)car atIndex:(NSInteger)index
{
    [subv setCarTintColorType:car.tintColorType];
    
    subv.licenceNumberLabel.text = car.licencenumber;
    subv.markView.hidden = !car.isDefault;
    
    if (!car.isDefault) {
        [subv.barView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(subv);
            make.height.mas_equalTo(2.5);
            make.left.equalTo(subv).offset(20);
            make.right.equalTo(subv.licenceNumberLabel.mas_right);
        }];
        [subv.licenceNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(subv.barView.mas_left);
            make.height.mas_equalTo(30);
            make.top.equalTo(subv.barView.mas_bottom).offset(2);
        }];
    }
    
    NSString *text = [self.model descForCarStatus:car];
    BOOL show = car.status == 3 || car.status == 0;
    [subv setShowBottomButton:show withText:text];
    
    NSString * brandStr = [NSString stringWithFormat:@"%@ %@", car.brand, car.seriesModel.seriesname];
    [subv setCellTitle:@"品牌车系" withValue:brandStr atIndex:0];
    [subv setCellTitle:@"具体车型" withValue:car.detailModel.modelname atIndex:1];
    [subv setCellTitle:@"购车时间" withValue:[car.purchasedate dateFormatForYYMM] atIndex:2];
    [subv setCellTitle:@"行驶城市" withValue:car.cityName atIndex:3];
    [subv setCellTitle:@"车架号码" withValue:car.classno atIndex:4];
    [subv setCellTitle:@"发动机号" withValue:car.engineno atIndex:5];
    NSString *priceStr = [NSString stringWithFormat:@"%@万元", [NSString formatForRoundPrice:car.price]];
    [subv setCellTitle:@"整车价格" withValue:priceStr atIndex:6];
    NSString *odoStr = [NSString stringWithFormat:@"%@万公里", [NSString formatForRoundPrice:car.odo/10000.00]];
    [subv setCellTitle:@"当前里程" withValue:odoStr atIndex:7];
    
    //汽车品牌logo
    [subv.logoView setImageByUrl:nil withType:ImageURLTypeThumbnail defImage:@"cm_logo_def" errorImage:@"cm_logo_def"];
    
    //爱车估值
    @weakify(self);
    [subv setValuationClickBlock:^(void) {
        [MobClick event:@"rp309_4"];
        @strongify(self);
        ValuationViewController *vc = [UIStoryboard vcWithId:@"ValuationViewController" inStoryboard:@"Valuation"];
        vc.carIndex = index;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    //上传行驶证
    [subv setBottomButtonClickBlock:^(UIButton *btn, CarListSubView *view) {
        @strongify(self);
        [self uploadDrivingLicenceWithCar:car subView:view];
    }];
    
    //编辑爱车信息
    [subv setBackgroundClickBlock:^(CarListSubView *view) {
        @strongify(self);
        if (self.model.disableEditingCar) {
            return ;
        }
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        vc.originCar = car;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)uploadDrivingLicenceWithCar:(HKMyCar *)car subView:(CarListSubView *)subView
{
    @weakify(self);
    [[[self.model rac_uploadDrivingLicenseWithTargetVC:self initially:^{
        
        [gToast showingWithText:@"正在上传..."];
    }] flattenMap:^RACStream *(NSString *url) {
        
        //更新行驶证的url，如果更新失败，重置为原来的行驶证url
        NSString *oldurl = car.licenceurl;
        car.licenceurl = url;
        MyCarStore *store = [MyCarStore fetchExistsStore];
        return [[[store updateCar:car] sendAndIgnoreError] catch:^RACSignal *(NSError *error) {
            car.licenceurl = oldurl;
            return [RACSignal error:error];
        }];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        car.status = 1;
        [subView setShowBottomButton:NO withText:[self.model descForCarStatus:car]];
        [gToast showSuccess:@"上传行驶证成功!"];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma - mark  PageSliderDelegate

- (void)addContentVCAtIndex:(NSInteger)index
{
    [self addContentAction:index];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger pageIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5); //过半取整
    
    [self.sliderView selectAtIndex:pageIndex];
}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    HKMyCar *car = [self.datasource safetyObjectAtIndex:[self.scrollView currentPage]];
//    self.model.currentCar = car;
//    if (self.model.allowAutoChangeSelectedCar) {
//        self.model.selectedCar = car;
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    HKMyCar *car = [self.datasource safetyObjectAtIndex:[self.scrollView currentPage]];
//    self.model.currentCar = car;
//    if (self.model.allowAutoChangeSelectedCar) {
//        self.model.selectedCar = car;
//    }
//}

@end
