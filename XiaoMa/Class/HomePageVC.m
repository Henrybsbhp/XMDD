//
//  HomePageVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//



#import "HomePageVC.h"
#import <Masonry.h>
#import "XiaoMa.h"
#import "UIImage+Utilities.h"
#import "UIView+Layer.h"
#import "GetSystemTipsOp.h"
#import "GetSystemHomePicOp.h"

#import "HKLoginModel.h"
#import "MyCarStore.h"
#import "GuideStore.h"
#import "PasteboardModel.h"

#import "CarWashTableVC.h"
#import "NewGainAwardVC.h"
#import "RescueHomeViewController.h"
#import "CommissionOrderVC.h"
#import "ADViewController.h"
#import "GasVC.h"
#import "ViolationViewController.h"
#import "ValuationViewController.h"
#import "HomeNewbieGuideVC.h"
#import "HomeSuspendedAdVC.h"
#import "MutualInsGrouponVC.h"
#import "MutualInsHomeVC.h"

#define WeatherRefreshTimeInterval 60 * 30
#define ItemCount 3.0

@interface HomePageVC ()<UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, weak) IBOutlet UIView *weatherView;
@property (nonatomic, strong)UIView *mainItemView;
@property (nonatomic, strong)UIView *secondaryItemView;
@property (nonatomic, strong)UIView *containerView;

@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) GuideStore *guideStore;

@property (nonatomic, strong)NSArray * homeItemArray;
@property (nonatomic, assign) BOOL isViewAppearing;
@property (nonatomic, assign) BOOL isShowSuspendedAd;

@property (nonatomic, strong)NSMutableArray * disposableArray;

@end


@implementation HomePageVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isViewAppearing = YES;
    [self.scrollView restartRefreshViewAnimatingWhenRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewAppearing = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = NO;

    [self setupProp];
    [gAppMgr loadLastLocationAndWeather];
    [self loadLastHomePicInfo];
    [gAdMgr loadLastAdvertiseInfo:AdvertisementHomePage];
    [gAdMgr loadLastAdvertiseInfo:AdvertisementCarWash];
    
    //自动登录
    [self autoLogin];
    //全局CarStore
    self.carStore = [MyCarStore fetchOrCreateStore];
    //设置新手引导
    [self setupGuideStore];
    //设置主页的滚动视图
    [self setupScrollView];
    [self setupWeatherView];
    
    [self.scrollView.refreshView addTarget:self action:@selector(reloadDatasource) forControlEvents:UIControlEventValueChanged];
    CKAsyncMainQueue(^{
        [self reloadDatasource];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.userInteractionEnabled = YES;
    CKAsyncMainQueue(^{
        if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
        {
            CGSize size = [self.containerView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, ceil(size.height));
        }
        else
        {
            ///只会出现在4，4s的机型上
//            CGFloat heigth = self.secondaryItemView.frame.size.height + self.secondaryItemView.frame.origin.x;
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 480);
        }
        [self showNewbieGuideAlertIfNeeded];
        [self showSuspendedAdIfNeeded];
    });
}

- (void)autoLogin
{
    HKLoginModel *loginModel = [[HKLoginModel alloc] init];
    //**********开始自动登录****************
    //该自动登录为无网络自动登录，会从上次的本地登录状态中恢复，不需要联网
    //之后调用的任何需要鉴权的http请求，如果发现上次的登录状态失效，将会自动触发后台刷新token和重新登录的机制。
    //再次登录成功后会自动重发这个http请求，不需要人工干预
    [[loginModel rac_autoLoginWithoutNetworking] subscribeNext:^(NSString *account) {
        [gAppMgr resetWithAccount:account];
        //开启推送接收队列
        gAppDelegate.pushMgr.notifyQueue.running = YES;
        gAppDelegate.openUrlQueue.running = YES;
        
        [self checkPasteboardModel];
    }];
}


#pragma mark - Setup
- (void)setupProp
{
    if (!self.disposableArray)
    {
        self.disposableArray = [NSMutableArray array];
    }
}

- (void)setupScrollView
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
    container.backgroundColor = [UIColor colorWithHex:@"#f4f4f4" alpha:1.0f];
    [self.scrollView addSubview:container];
    self.containerView = container;
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    //广告
    [self setupADViewInContainer:container];
    
    //天气视图
    self.weatherView.backgroundColor = [UIColor whiteColor];
    [self.weatherView removeFromSuperview];
    [container addSubview:self.weatherView];
    
    CGFloat deviceWidth = gAppMgr.deviceInfo.screenSize.width;
    CGFloat dHeight = gAppMgr.deviceInfo.screenSize.height < 568.0 ? 568.0 : gAppMgr.deviceInfo.screenSize.height;

    @weakify(self);
    [self.weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.adctrl.adView.mas_bottom);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        
        CGFloat height = 84.0f / 1136.0f * dHeight;
        make.height.mas_equalTo(@(height));
    }];

    ///第一栏
    UIView * mainView = [[UIView alloc] init];
    mainView.tag = 101;
    mainView.backgroundColor = [UIColor whiteColor];
    [container addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.weatherView.mas_bottom);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        CGFloat height = 164.0f / 1136.0f * dHeight;
        make.height.mas_equalTo(@(height));
    }];
    
    CGFloat width1 =  284.0f / 640.0f * deviceWidth;
    CGFloat spaceX = (deviceWidth - width1 * 2) / 3;
    [self addLineToView:mainView withDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsMake(0, spaceX, 0, spaceX)];
    [self addLineToView:mainView withDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    
    UIView * secondaryView = [[UIView alloc] init];
    secondaryView.tag = 102;
    secondaryView.backgroundColor = [UIColor whiteColor];
    [container addSubview:secondaryView];
    [secondaryView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        CGFloat space = 16.0f / 1136.0f * dHeight;
        make.top.equalTo(mainView.mas_bottom).offset(space);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
    }];
    
    [self addLineToView:secondaryView withDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    
    // 刷新第一栏
    [self setupFirstView];

 
    //洗车
    NSString * carwashBtnName = @"hp_carwash_big_2_5";
    CGFloat height = 232.0f / 1136.0f * dHeight;
    
    CGFloat width = 447.0f / 640.0f  * deviceWidth;
    UIButton *carwashBtn = [self functionalButtonWithImageName:carwashBtnName action:@selector(actionWashCar:) inContainer:secondaryView hasBorder:NO andPicUrl:gAppMgr.homePicModel.yjxcPic];
    carwashBtn.tag = 20201;
    [carwashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(secondaryView);
        make.width.mas_equalTo(width);
        make.top.equalTo(secondaryView);
        make.height.mas_equalTo(height);
    }];
    
    [self addLineToView:carwashBtn withDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsZero];
    [self addLineToView:carwashBtn withDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    
    //每周礼券
    NSString * couponBtnName = @"hp_coupon_big_2_5";
    UIButton *couponBtn = [self functionalButtonWithImageName:couponBtnName action:@selector(actionAward:) inContainer:secondaryView hasBorder:NO andPicUrl:gAppMgr.homePicModel.mzlqpic];
    couponBtn.tag = 20202;
    [couponBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(carwashBtn.mas_right);
        make.right.equalTo(secondaryView);
        make.top.equalTo(secondaryView);
        make.height.equalTo(carwashBtn);
    }];
    
    [self addLineToView:couponBtn withDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsZero];
    [self addLineToView:couponBtn withDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    [self addLineToView:couponBtn withDirection:CKViewBorderDirectionLeft withEdge:UIEdgeInsetsZero];
    
    //保险
    UIButton *insuranceBtn = [self functionalButtonWithImageName:@"hp_insurance_2_5" action:@selector(actionInsurance:) inContainer:secondaryView hasBorder:NO andPicUrl:gAppMgr.homePicModel.bxfwpic];
    insuranceBtn.tag = 20203;
    [insuranceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(secondaryView.mas_left);
        make.top.equalTo(carwashBtn.mas_bottom);
        make.width.equalTo(mainView.mas_width).multipliedBy(0.5);
        
        CGFloat height = 280.0f / 1136.0f * dHeight;
        make.height.mas_equalTo(height);
    }];
    
    [self addLineToView:insuranceBtn withDirection:CKViewBorderDirectionRight withEdge:UIEdgeInsetsZero];

    //专业救援
    UIButton *rescueBtn = [self functionalButtonWithImageName:@"hp_rescue_2_5" action:@selector(actionRescue:) inContainer:secondaryView hasBorder:NO andPicUrl:gAppMgr.homePicModel.zyjypic];
    rescueBtn.tag = 20204;
    [rescueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(insuranceBtn.mas_right);
        make.top.equalTo(insuranceBtn);
        make.width.equalTo(insuranceBtn.mas_width);
        make.height.equalTo(insuranceBtn.mas_height).multipliedBy(0.5f);
    }];
    
    [self addLineToView:rescueBtn withDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    
    //年检协办
    UIButton *commissionBtn = [self functionalButtonWithImageName:@"hp_commission_2_5" action:@selector(actionCommission:) inContainer:secondaryView hasBorder:NO andPicUrl:gAppMgr.homePicModel.njxbpic];
    commissionBtn.tag = 20205;
    [commissionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rescueBtn);
        make.top.equalTo(rescueBtn.mas_bottom);
        make.width.equalTo(insuranceBtn.mas_width);
        make.height.equalTo(insuranceBtn.mas_height).multipliedBy(0.5f);
    }];
    
    [secondaryView mas_updateConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(insuranceBtn.mas_bottom).offset(1);
    }];
    
    [container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(secondaryView);
    }];
}

- (void)setupADViewInContainer:(UIView *)container
{
    self.adctrl = [ADViewController vcWithADType:AdvertisementHomePage boundsWidth:self.view.frame.size.width
                                        targetVC:self mobBaseEvent:@"rp101_10"];
    
    CGFloat height = floor(self.adctrl.adView.frame.size.height);
    [container addSubview:self.adctrl.adView];
    [self.adctrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container);
        make.right.equalTo(container);
        make.top.equalTo(container);
        make.height.mas_equalTo(height);
    }];
}

- (void)setupBottomViewWithUpper:(UIView *)upper
{
    UIView *bottomView = [UIView new];
    UIImageView *imgView = [UIImageView new];
    imgView.image = [UIImage imageNamed:@"hp_bottom"];
    [bottomView addSubview:imgView];
    [self.scrollView addSubview:bottomView];
    self.bottomView = bottomView;
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.height.mas_equalTo(47);
        make.top.greaterThanOrEqualTo(upper.mas_bottom).offset(2).priorityMedium();
        make.bottom.greaterThanOrEqualTo(self.bgView).priorityHigh();
    }];
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView);
    }];
}

- (void)setupNavigationLeftBar:(NSString *)city
{
    if (city.length)
    {
        UIBarButtonItem *cityBtn = [[UIBarButtonItem alloc] initWithTitle:city style:UIBarButtonItemStyleDone
                                                                   target:self action:nil];
        self.navigationItem.leftBarButtonItem = cityBtn;
    }
    else
    {
        
        UIBarButtonItem *retrybtn = [[UIBarButtonItem alloc] initWithTitle:@"定位失败" style:UIBarButtonItemStyleDone
                                                                    target:self action:@selector(reloadDatasource)];
        self.navigationItem.leftBarButtonItem = retrybtn;
    }
    self.navigationItem.leftBarButtonItem.action=@selector(umeng);
}

- (void)umeng
{
    [MobClick event:@"rp101_1"];
}

- (void)setupNavigationRightBar
{
    
}

- (void)setupWeatherView:(NSString *)picName andTemperature:(NSString *)temp andTemperaturetip:(NSString *)tip
          andRestriction:(NSString *)restriction
{
    UIImageView * weatherImage = (UIImageView *)[self.weatherView searchViewWithTag:20201];
    UILabel * tempLb = (UILabel *)[self.weatherView searchViewWithTag:20202];
    UILabel * restrictionLb = (UILabel *)[self.weatherView searchViewWithTag:20204];
    UILabel * tipLb = (UILabel *)[self.weatherView searchViewWithTag:20206];
    [weatherImage setImageByUrl:picName withType:ImageURLTypeOrigin defImage:nil errorImage:nil];
    
    tempLb.text = temp;
    NSMutableIndexSet * set = [NSMutableIndexSet indexSet];
    [set addIndex:2];
    [set addIndex:4];
    restrictionLb.attributedText = [self formatRestrictionLb:set withString:restriction];
    
    if(tip.length > 0)
    {
        [self setupLineSpace:tipLb withText:tip];
    }
}

- (void)setupWeatherView
{
    
    UIImageView * weatherImage = (UIImageView *)[self.weatherView searchViewWithTag:20201];
    UILabel * tempLb = (UILabel *)[self.weatherView searchViewWithTag:20202];
    UILabel * restrictionLb = (UILabel *)[self.weatherView searchViewWithTag:20204];
    UILabel * tipLb = (UILabel *)[self.weatherView searchViewWithTag:20206];
    UIView *rightContainerV = (UIView *)[self.weatherView searchViewWithTag:20200];
    
    RAC(tempLb, text) = RACObserve(gAppMgr, temperature);
    [[RACObserve(gAppMgr, restriction) distinctUntilChanged] subscribeNext:^(NSString *text) {
        rightContainerV.hidden = text.length == 0;
        
        rightContainerV.hidden = text.length == 0;
        restrictionLb.text = text;
    }];
    
    [RACObserve(gAppMgr, temperaturetip) subscribeNext:^(NSString *text) {
        
        if (text.length > 0) {
            [self setupLineSpace:tipLb withText:text];
        }
    }];
    
    NSString * picName = @"";
    NSArray * tArray = [gAppMgr.temperaturepic componentsSeparatedByString:@"/"];
    if (tArray.count)
    {
        picName = [tArray lastObject];
    }
    weatherImage.image = [UIImage imageNamed:picName];
    
    [[RACObserve(gAppMgr, temperaturepic)distinctUntilChanged] subscribeNext:^(id x) {
        NSString * picName = [[x componentsSeparatedByString:@"/"] lastObject];
        weatherImage.image = [UIImage imageNamed:picName];
    }];
}

- (void)setupFirstView
{
    UIView *firstView = (UIView *)[self.view searchViewWithTag:101];
//    [firstView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger i = 0; i < self.homeItemArray.count; i++)
    {
        HomeItem *item = [self.homeItemArray safetyObjectAtIndex:i];
        
        [self mainButtonWithImageName:item.defaultImageName title:item.homeItemTitle index:i jumpUrl:item.homeItemRedirect inContainer:firstView andPicUrl:item.homeItemPicUrl];
    }
}



#pragma mark - Guide
- (void)setupGuideStore
{
    self.guideStore = [GuideStore fetchOrCreateStore];
    @weakify(self);
    [self.guideStore subscribeWithTarget:self domain:kDomainNewbiewGuide receiver:^(CKStore *store, CKEvent *evt) {
        [[evt signal] subscribeNext:^(id x) {
            @strongify(self);
            [self showNewbieGuideAlertIfNeeded];
            [self showSuspendedAdIfNeeded];
        }];
    }];
}

//刷新是否显示新手引导
- (void)showNewbieGuideAlertIfNeeded
{
    if (self.guideStore.shouldShowNewbieGuideAlert && self.isViewAppearing) {
        [HomeNewbieGuideVC presentInTargetVC:self];
    }
}

- (void)showSuspendedAdIfNeeded
{
    if (!self.guideStore.shouldDisablePopupAd && self.isViewAppearing && !self.isShowSuspendedAd) {
        
        self.isShowSuspendedAd = YES;
        
        @weakify(self);
        RACSignal *signal = [gAdMgr rac_getAdvertisement:AdvertisementAlert];
        [[signal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *ads) {
            
            @strongify(self);
            //若弹出抢登登录框，则不弹出广告
            if (!gAppDelegate.errorModel.alertView && ads.count > 0) {
                
                [HomeSuspendedAdVC presentInTargetVC:self withAdList:ads];
            }
        }];
    }
}

#pragma mark - Action
- (IBAction)actionCallCenter:(id)sender
{
//    [MobClick event:@"rp101_2"];
//    NSString * number = @"4007111111";
//    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
    MutualInsHomeVC * vc = [UIStoryboard vcWithId:@"MutualInsHomeVC" inStoryboard:@"MutualInsJoin"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)actionChooseCity:(id)sender
{
}

- (void)actionWashCar:(id)sender
{
    [MobClick event:@"rp101_3"];
    CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionInsurance:(id)sender
{
    [MobClick event:@"rp101_4"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        UIViewController *vc = [UIStoryboard vcWithId:@"InsuranceVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionRescue:(id)sender
{
    [MobClick event:@"rp101_5"];
    RescueHomeViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueHomeViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCommission:(id)sender
{
    [MobClick event:@"rp101_6"];
    CommissionOrderVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionOrderVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionAward:(id)sender
{
    [MobClick event:@"rp101_11"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        NewGainAwardVC * vc = [awardStoryboard instantiateViewControllerWithIdentifier:@"NewGainAwardVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)actionAddGas:(id)sender
{
    [MobClick event:@"rp101_12"];
    GasVC *vc = [UIStoryboard vcWithId:@"GasVC" inStoryboard:@"Gas"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionQueryViolation:(id)sender
{
    /**
     *  违章查询事件
     */
    [MobClick event:@"rp101_14"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        
        ViolationViewController * vc = [violationStoryboard instantiateViewControllerWithIdentifier:@"ViolationViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionCarValuation:(id)sender
{
    /**
     *  二手车估值事件
     */
    [MobClick event:@"rp101_15"];
    ValuationViewController *vc = [UIStoryboard vcWithId:@"ValuationViewController" inStoryboard:@"Valuation"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Utility

- (void)reloadDatasource
{
    @weakify(self);
    RACSignal *sig1 = [[[[[gMapHelper rac_getInvertGeoInfo] take:1] initially:^{
        @strongify(self);
        [self setupNavigationLeftBar:@"定位中..."];
    }] doError:^(NSError *error) {
        @strongify(self);
        [self setupNavigationLeftBar:nil];
        [self handleGPSError:error];
    }] doNext:^(AMapReGeocode *regeo) {
        @strongify(self);
        NSString * cityStr;
        cityStr = regeo.addressComponent.city.length ? regeo.addressComponent.city : regeo.addressComponent.province;
        [self setupNavigationLeftBar:cityStr];
        if (![HKAddressComponent isEqualAddrComponent:gAppMgr.addrComponent AMapAddrComponent:regeo.addressComponent]) {
            gAppMgr.addrComponent = [HKAddressComponent addressComponentWith:regeo.addressComponent];
        }
    }];
    
    // 获取天气信息
    [[[[sig1 initially:^{
        @strongify(self);
        [self.scrollView.refreshView beginRefreshing];
    }] flattenMap:^RACStream *(AMapReGeocode *regeo) {
        @strongify(self);
        [self.adctrl reloadDataWithForce:YES completed:nil];
        return [self rac_getWeatherInfoWithReGeocode:regeo];
    }] finally:^{
        @strongify(self);
        [self.scrollView.refreshView endRefreshing];
    }] subscribeNext:^(id x) {
        
    }];
    
    GetSystemHomePicOp * op = [[GetSystemHomePicOp alloc] init];
    [[op rac_postRequest] subscribeNext:^(GetSystemHomePicOp * op) {
        
        gAppMgr.homePicModel = op.homeModel;
        [gAppMgr saveHomePicInfo];
        self.homeItemArray = op.homeModel.homeItemArray;
        [self refreshFirstView];
        [self refreshSecondView];
    }];
}

- (RACSignal *)rac_getWeatherInfoWithReGeocode:(AMapReGeocode *)regeo
{
    GetSystemTipsOp * op = [GetSystemTipsOp operation];
    op.province = regeo.addressComponent.province;
    op.city = regeo.addressComponent.city.length ? regeo.addressComponent.city : regeo.addressComponent.province;
    op.district = regeo.addressComponent.district;
    return [[[[op rac_postRequest] doNext:^(GetSystemTipsOp * op) {
        
        gAppMgr.temperature = op.rsp_temperature;
        gAppMgr.temperaturepic = op.rsp_temperaturepic;
        gAppMgr.temperaturetip = op.rsp_temperaturetip;
        gAppMgr.restriction = op.rsp_restriction;
        
        [gAppMgr saveInfo:op.rsp_temperature forKey:Temperature];
        [gAppMgr saveInfo:op.rsp_temperaturepic forKey:Temperaturepic];
        [gAppMgr saveInfo:op.rsp_temperaturetip forKey:Temperaturetip];
        [gAppMgr saveInfo:op.rsp_restriction forKey:Restriction];
        NSString * dateStr = [[NSDate date] dateFormatForDT15];
        [gAppMgr saveInfo:dateStr forKey:LastWeatherTime];
    }] doError:^(NSError *error) {
        
        [gToast showError:@"天气获取失败"];
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal empty];
    }];
}

- (void)handleGPSError:(NSError *)error
{
    switch (error.code) {
        case kCLErrorDenied:
        {
            if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开,然后重启应用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置", nil];
                
                [[av rac_buttonClickedSignal] subscribeNext:^(id x) {
                    
                    if ([x integerValue] == 1)
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }];
                [av show];
            }
            else
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开，然后重启应用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                
                [av show];
            }
            break;
        }
        case LocationFail:
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"城市定位失败,请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            
            [av show];
        }
        default:
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"定位失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            
            [av show];
            break;
        }
    }
}




- (UIButton *)functionalButtonWithImageName:(NSString *)imgName action:(SEL)action inContainer:(UIView *)container hasBorder:(BOOL)border andPicUrl:(NSString *)picUrl
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (border)
    {
        btn.layer.borderColor = [UIColor colorWithWhite:0.84 alpha:1.0].CGColor;
        btn.layer.borderWidth = 0.5;
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = YES;
    }
    [container addSubview:btn];
    
    if (picUrl)
    {
        [self requestHomePicWithBtn:btn andUrl:picUrl andDefaultPic:imgName errPic:imgName];
    }
    else
    {
        UIImage *img = [UIImage imageNamed:imgName];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
    }
    return btn;
}

- (UIButton *)mainButtonWithImageName:(NSString *)imgName title:(NSString *)title index:(NSInteger)index jumpUrl:(NSString *)url inContainer:(UIView *)container andPicUrl:(NSString *)picUrl
{
    NSInteger tag = 20101;
    UIButton * btn = [self functionalButtonWithImageName:imgName action:nil inContainer:container hasBorder:NO andPicUrl:picUrl];
    RACDisposable * disposable = [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self jumpToViewControllerByUrl:url];
    }];
    [self.disposableArray safetyAddObject:disposable];
    btn.tag = tag + index * 2;
    UILabel * lb = [[UILabel alloc] init];
    lb.text = title;
    lb.font = [UIFont systemFontOfSize:12];
    lb.textColor = [UIColor colorWithHex:@"#454545" alpha:1.0f];
    [container addSubview:lb];
    lb.tag = tag + index * 2 + 1;
    
    
    CGFloat dHeight = gAppMgr.deviceInfo.screenSize.height < 568.0 ? 568.0 : gAppMgr.deviceInfo.screenSize.height;
    CGFloat diameter = 95.0f / 1136 * dHeight;
    CGFloat totalHeight = 130.0f / 1136 * dHeight;
    CGFloat containHeight = 164.0f / 1136.0f * dHeight;
    CGFloat multiplied = (index * 2.0 + 1) / ItemCount;
    CGFloat space = 10.f / 1136 * dHeight;
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(diameter);
        make.height.mas_equalTo(diameter);
        make.top.equalTo(container).offset(((containHeight - totalHeight)/2));
        make.centerX.equalTo(container).multipliedBy(multiplied);
    }];
    
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(btn);
        make.top.equalTo(btn.mas_bottom).offset(space);
    }];
    
    return btn;
}

- (void)setupLineSpace:(UILabel *)label withText:(NSString *)text
{
    if (IOSVersionGreaterThanOrEqualTo(@"7.0")) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];//调整行间距
        
        NSDictionary *attr = @{NSParagraphStyleAttributeName: paragraphStyle};
        label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attr];
    }
    else {
        label.text = text;
    }
}

- (void)addLineToView:(UIView *)view withDirection:(CKViewBorderDirection)d
             withEdge:(UIEdgeInsets)edge
{
    UIImageView *topline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Horizontaline"]];
    
    UIImageView *bottomline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Horizontaline2"]];
    
    UIImageView *leftline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Verticalline"]];

    UIImageView *rightline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Verticalline2"]];

    switch (d) {
        case CKViewBorderDirectionLeft:
        {
            [view addSubview:leftline];
            [leftline mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(view);
                make.bottom.equalTo(view);
                make.width.mas_equalTo(@1);
                make.left.equalTo(view);
            }];
            break;
        }
        case CKViewBorderDirectionRight:
        {
            [view addSubview:rightline];
            [rightline mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(view);
                make.bottom.equalTo(view);
                make.width.mas_equalTo(@1);
                make.right.equalTo(view);
            }];
            break;
        }
        case CKViewBorderDirectionTop:
        {
            [view addSubview:topline];
            [topline mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(view).offset(edge.left);
                make.right.equalTo(view).offset(-edge.right);
                make.height.mas_equalTo(@1);
                make.top.equalTo(view);
            }];
            break;
        }
        case CKViewBorderDirectionBottom:
        {
            [view addSubview:bottomline];
            [bottomline mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(view);
                make.right.equalTo(view);
                make.height.mas_equalTo(@1);
                make.bottom.equalTo(view);
            }];
            break;
        }
            
        default:
            break;
    }
}

- (NSAttributedString *)formatRestrictionLb:(NSIndexSet *)rangeSet  withString:(NSString *)string
{
     NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    for (NSInteger i = 0 ; i < string.length ; i++)
    {
        NSRange r = NSMakeRange(i, 1);
        NSString * c = [string substringWithRange:r];
        if ([rangeSet containsIndex:i])
        {
            NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                    NSForegroundColorAttributeName:HEXCOLOR(@"#ff563a")};
            NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:c attributes:attr2];
            [str appendAttributedString:attrStr2];
        }
        else
        {
            NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName: HEXCOLOR(@"#657377")};
            NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:c attributes:attr1];
            [str appendAttributedString:attrStr1];
        }
    }
    return str;
}

//刷新第一栏
- (void)refreshFirstView
{
    UIView *firstView = (UIView *)[self.view searchViewWithTag:101];
    
    for (RACDisposable * disposable in self.disposableArray)
    {
        [disposable dispose];
    }
    [self.disposableArray removeAllObjects];
    
    for (NSInteger i = 0; i < self.homeItemArray.count; i++)
    {
        HomeItem *item = [self.homeItemArray safetyObjectAtIndex:i];
        NSInteger btnTag = 20101 + i * 2;
        NSInteger lbTag = 20101 + i * 2 + 1;
        UIButton * btn = (UIButton *)[firstView searchViewWithTag:btnTag];
        UILabel * lb = (UILabel *)[firstView searchViewWithTag:lbTag];
        
        lb.text = item.homeItemTitle;
        [self requestHomePicWithBtn:btn andUrl:item.homeItemPicUrl andDefaultPic:nil errPic:nil];
        
        RACDisposable * disposable = [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [self jumpToViewControllerByUrl:item.homeItemRedirect];
        }];
        [self.disposableArray safetyAddObject:disposable];
    }
}
//刷新第二栏
- (void)refreshSecondView
{
    UIView *secondView = (UIView *)[self.view searchViewWithTag:102];
    UIButton *carwashBtn = (UIButton *)[secondView searchViewWithTag:20201];
    UIButton *couponBtn = (UIButton *)[secondView searchViewWithTag:20202];
    UIButton *insuranceBtn = (UIButton *)[secondView searchViewWithTag:20203];
    UIButton *rescueBtn = (UIButton *)[secondView searchViewWithTag:20204];
    UIButton *commissionBtn = (UIButton *)[secondView searchViewWithTag:20205];
    
    [self requestHomePicWithBtn:carwashBtn andUrl:gAppMgr.homePicModel.yjxcPic andDefaultPic:@"hp_carwash_big_2_5" errPic:@"hp_carwash_big_2_5"];
    [self requestHomePicWithBtn:couponBtn andUrl:gAppMgr.homePicModel.mzlqpic andDefaultPic:@"hp_coupon_big_2_5" errPic:@"hp_coupon_big_2_5"];
    [self requestHomePicWithBtn:insuranceBtn andUrl:gAppMgr.homePicModel.bxfwpic andDefaultPic:@"hp_insurance_2_5" errPic:@"hp_insurance_2_5"];
    [self requestHomePicWithBtn:rescueBtn andUrl:gAppMgr.homePicModel.zyjypic andDefaultPic:@"hp_rescue_2_5" errPic:@"hp_rescue_2_5"];
    [self requestHomePicWithBtn:commissionBtn andUrl:gAppMgr.homePicModel.njxbpic andDefaultPic:@"hp_commission_2_5" errPic:@"hp_commission_2_5"];
}

- (void)requestHomePicWithBtn:(UIButton *)btn andUrl:(NSString *)url andDefaultPic:(NSString *)pic1 errPic:(NSString *)pic2
{
    [[gMediaMgr rac_getImageByUrl:url withType:ImageURLTypeOrigin defaultPic:pic1 errorPic:pic2] subscribeNext:^(id x) {
        
        if (![x isKindOfClass:[UIImage class]])
            return ;
        [UIView transitionWithView:btn
                          duration:1.0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            [btn setBackgroundImage:x forState:UIControlStateNormal];
                            [btn setBackgroundImage:x forState:UIControlStateHighlighted];
                            btn.alpha = 1.0;
                        } completion:nil];
    }];
}

- (void)loadLastHomePicInfo
{
    [gAppMgr loadLastHomePicInfo];
    if (!gAppMgr.homePicModel.homeItemArray.count)
    {
        HomeItem * item1 = [[HomeItem alloc] initWithTitlt:@"油卡充值" picUrl:nil andUrl:@"xmdd://j?t=g" imageName:@"hp_addgas_2_5"];
        HomeItem * item2 = [[HomeItem alloc] initWithTitlt:@"违章查询" picUrl:nil andUrl:@"xmdd://j?t=vio" imageName:@"hp_violation_2_5"];
        HomeItem * item3 = [[HomeItem alloc] initWithTitlt:@"爱车估值" picUrl:nil andUrl:@"xmdd://j?t=val" imageName:@"hp_estimate_2_5"];
        self.homeItemArray = @[item1,item2,item3];
    }
    else
    {
        self.homeItemArray = gAppMgr.homePicModel.homeItemArray;
    }
}

- (void)jumpToViewControllerByUrl:(NSString *)url
{
    [gAppMgr.navModel pushToViewControllerByUrl:url];
}

- (void)checkPasteboardModel
{
    [gAppDelegate.pasteboardoModel checkPasteboard];
}

@end
