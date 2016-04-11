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
#import "AddCloseAnimationButton.h"
#import "HKPopoverView.h"
#import "UpdateCarOp.h"
#import "UIView+RoundedCorner.h"

#import "ValuationHomeVC.h"

@interface CarsListVC () <UIScrollViewDelegate,PageSliderDelegate>

@property (nonatomic, assign) BOOL isViewAppearing;
@property (nonatomic, assign) BOOL isBackToMine;

@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) HKPageSliderView * sliderView;

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIView *emptyContentView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerBgView;
@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *carStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;

@property (nonatomic, weak) HKPopoverView *popoverMenu;

- (IBAction)editAction:(id)sender;

- (IBAction)backAction:(id)sender;

@end

@implementation CarsListVC

- (void)dealloc
{
    DebugLog(@"CarsListVC dealloc");
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.emptyView.hidden ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)awakeFromNib
{
    _model = [[MyCarListVModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isViewAppearing = YES;
    self.isBackToMine = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewAppearing = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![self.navigationController.topViewController isEqual:self]) {
        if (self.isViewAppearing) {
            CKAsyncMainQueue(^{
                if (!self.isBackToMine) {
                    [self.navigationController setNavigationBarHidden:NO animated:NO];
                }
            });
        }
        else {
            if (!self.isBackToMine) {
                [self.navigationController setNavigationBarHidden:NO animated:animated];
            }
        }
    }
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUI];
    [self setupCarStore];
    [[self.carStore getAllCars] send];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUI
{
    UIButton *addCarButton = [self.emptyContentView viewWithTag:1002];
    @weakify(self);
    [[addCarButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [self.defaultLabel setCornerRadius:3 withBorderColor:HEXCOLOR(@"#FDFE28") borderWidth:0.5 backgroundColor:HEXCOLOR(@"#18D06A") backgroundImage:nil contentMode:UIViewContentModeScaleToFill];
    
    [self.defaultLabel setCornerRadius:3];
    [self.defaultLabel setBorderWidth:0.5];
    [self.defaultLabel setBorderColor:HEXCOLOR(@"#FDFE28")];
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
        self.emptyView.hidden = NO;
        self.emptyContentView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        
        @strongify(self);
        //防止加载动画一闪而过
        CKAfter(0.5, ^{
            if (![self.view isShowDefaultEmptyView] && self.datasource.count > 0) {
                self.tableView.hidden = NO;
                self.emptyView.hidden = YES;
            }
            else {
                self.tableView.hidden = YES;
                self.emptyView.hidden = NO;
            }
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self setNeedsStatusBarAppearanceUpdate];
            }
            [self.view stopActivityAnimation];
        });
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

        if (self.datasource.count == 0) {
            CKAfter(0.5, ^{
                self.emptyContentView.hidden = NO;
            });
        }
        else {
            [self refreshTableView];
        }
        _originCarID = nil;
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        
        @weakify(self);
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取爱车信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [[self.carStore getAllCars] send];
        }];
    }];
}

- (void)refreshTableView
{
    //防止加载动画一闪而过
    CKAfter(0.5, ^{
        [self.view hideDefaultEmptyView];
        [self.view hideIndicatorText];
        self.tableView.hidden = NO;
        self.emptyView.hidden = YES;
    });
    
    @weakify(self);
    [self.headerBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view.mas_top).offset(0);
    }];
    
    [[RACObserve(self.model, selectedCar) distinctUntilChanged] subscribeNext:^(HKMyCar *car) {
        @strongify(self);
        self.carNumberLabel.text = car.licencenumber;
        self.defaultLabel.hidden = !car.isDefault;
        self.carStateLabel.text= [self.model descForCarStatus:car];
    }];
    
    NSInteger index = NSNotFound;
    
    if (self.model.currentCar) {
        index = [self.datasource indexOfObject:self.model.currentCar];
    }
    if (index == NSNotFound) {
        index = 0;
    }
    
    [self.tableView reloadData];
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 390;
    }
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self carCellAtIndexPath:indexPath];
    }
    else {
        cell = [self bottomCellAtIndexPath:indexPath];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - About Cell

- (UITableViewCell *)carCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"CarCell" forIndexPath:indexPath];
    UIView *view= [cell.contentView viewWithTag:1001];
    
    NSMutableArray *carNumArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.datasource.count; i++) {
        HKMyCar *car = self.datasource[i];
        [carNumArray addObject:car.licencenumber];
    }
    
    if (carNumArray.count > 0) {
        HKPageSliderView *pageSliderView = [[HKPageSliderView alloc] initWithFrame:view.bounds andTitleArray:carNumArray andStyle:HKTabBarStyleUnderCorner atIndex:[self.datasource indexOfObject:self.model.currentCar]];
        pageSliderView.contentScrollView.delegate = self;
        pageSliderView.delegate = self;
        
        if (view.subviews.count != 0) {
            [view removeSubviews];
        }
        [view addSubview:pageSliderView];
        self.sliderView = pageSliderView;//赋值全局
        [self observeScrollViewOffset];
        [self addContentView];
    }
    return cell;
}

-(void)addContentView
{
    for (int i = 0; i < self.datasource.count; i ++) {
        HKMyCar *car = self.datasource[i];
        
        CarListSubVC * contentVC = [[CarListSubVC alloc] init];
        [self addChildViewController:contentVC];
        contentVC.car = car;
        contentVC.view.frame = CGRectMake(i * self.view.bounds.size.width, 0, self.view.bounds.size.width, 600);
        
        [self.sliderView.contentScrollView addSubview:contentVC.view];
    }
}

- (UITableViewCell *)bottomCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"BottomCell" forIndexPath:indexPath];
    UIButton * uploadButton = [cell.contentView viewWithTag:1001];
    UILabel * uploadStateLabel = [cell.contentView viewWithTag:1002];
    UIButton * valuationButton = [cell.contentView viewWithTag:1003];
    
    @weakify(self);
    [[RACObserve(self.model, selectedCar) distinctUntilChanged] subscribeNext:^(HKMyCar *car) {
        @strongify(self);
        uploadStateLabel.text = [self.model uploadButtonStateForCar:self.model.selectedCar];
    }];
    
    [[[uploadButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self uploadDrivingLicenceWithCar:self.model.currentCar];
    }];
    
    [[[valuationButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [MobClick event:@"rp309_4"];
        @strongify(self);
        ValuationHomeVC *vc = [UIStoryboard vcWithId:@"ValuationHomeVC" inStoryboard:@"Valuation"];
        vc.carIndex = self.sliderView.currentIndex;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return cell;
}

#pragma mark - Action

- (IBAction)editAction:(id)sender {
    AddCloseAnimationButton * closeButton = sender;
    BOOL closing = closeButton.closing;
    [closeButton setClosing:!closing WithAnimation:YES];
    if (closing && self.popoverMenu) {
        [self.popoverMenu dismissWithAnimated:YES];
    }
    else if (!closing && !self.popoverMenu) {
        NSArray * itemsArray = @[[HKPopoverViewItem itemWithTitle:@"添加爱车" imageName:@"mec_addcar"], [HKPopoverViewItem itemWithTitle:@"编辑爱车" imageName:@"mec_edit"]];
        
        HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 160) items:itemsArray];
        @weakify(self);
        [popover setDidSelectedBlock:^(NSUInteger index) {
            @strongify(self);
            if (index == 0) {
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                vc.originCar = self.model.currentCar;
                vc.model = self.model;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
        
        [popover setDidDismissedBlock:^(BOOL animated) {
            [closeButton setClosing:NO WithAnimation:animated];
        }];
        [popover showAtAnchorPoint:CGPointMake(self.navigationController.view.frame.size.width-33, 60)
                            inView:self.navigationController.view dismissTargetView:self.view animated:YES];
        self.popoverMenu = popover;
    }
}

- (IBAction)backAction:(id)sender {
    //如果爱车信息不完整
    if (self.model.allowAutoChangeSelectedCar && self.model.selectedCar && ![self.model.selectedCar isCarInfoCompleted]) {
        
        HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
        alert.topTitle = @"温馨提示";
        alert.imageName = @"mins_bulb";
        alert.message = @"您的爱车信息不完整，是否现在完善？";
        @weakify(self);
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"放弃" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
            @strongify(self);
            if (self.model.originVC) {
                [self.navigationController popToViewController:self.model.originVC animated:YES];
            }
            else {
                self.isBackToMine = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"去完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            @strongify(self);
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
            self.isBackToMine = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.model.finishBlock) {
            self.model.finishBlock(self.model.selectedCar);
        }
    }
}

- (void)uploadDrivingLicenceWithCar:(HKMyCar *)car
{
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
        
        car.status = 1;
        [gToast showSuccess:@"上传行驶证成功!"];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
    if (scrollView == self.sliderView.contentScrollView) {
        NSInteger pageIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width);
        [self.sliderView selectAtIndex:pageIndex];
        
        HKMyCar *car = [self.datasource safetyObjectAtIndex:self.sliderView.currentIndex];
        self.model.currentCar = car;
        if (self.model.allowAutoChangeSelectedCar) {
            self.model.selectedCar = car;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.sliderView.contentScrollView) {
        
        NSInteger pageIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width);
        [self.sliderView selectAtIndex:pageIndex];
        
        HKMyCar *car = [self.datasource safetyObjectAtIndex:self.sliderView.currentIndex];
        self.model.currentCar = car;
        if (self.model.allowAutoChangeSelectedCar) {
            self.model.selectedCar = car;
        }
    }
}

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
