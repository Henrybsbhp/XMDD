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
#import "NSString+MD5.h"
#import "UIImage+Utilities.h"
#import "UIView+Layer.h"
#import "GetSystemTipsOp.h"

#import "HKLoginModel.h"
#import "MyCarStore.h"

#import "CarWashTableVC.h"
#import "RescueViewController.h"
#import "ServiceViewController.h"
#import "WebVC.h"
#import "RescureViewController.h"
#import "RescureHomeViewController.h"
#import "CommissionViewController.h"
#import "CommissonOrderVC.h"
#import "GainAwardViewController.h"
#import "GainedViewController.h"
#import "WelcomeViewController.h"
#import "CheckAwardViewController.h"
#import "ADViewController.h"
#import "CollectionChooseVC.h"
#import "GasVC.h"
#import "PaymentSuccessVC.h"
#import "PaymentCenterViewController.h"
#import "CommissonConfirmVC.h"
#import "ViolationItemViewController.h"
#import "ViolationViewController.h"
#import "ValuationViewController.h"

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
@end

@implementation HomePageVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp101"];
    [self.scrollView restartRefreshViewAnimatingWhenRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp101"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = NO;

    [gAppMgr loadLastLocationAndWeather];
    [gAdMgr loadLastAdvertiseInfo:AdvertisementHomePage];
    [gAdMgr loadLastAdvertiseInfo:AdvertisementCarWash];
    
    //自动登录
    [self autoLogin];
    //全局CarStore
    self.carStore = [MyCarStore fetchOrCreateStore];
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
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 460);
        }
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
    }];
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
    secondaryView.backgroundColor = [UIColor whiteColor];
    [container addSubview:secondaryView];
    [secondaryView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        CGFloat space = 8.0f / 1136.0f * dHeight;
        if (dHeight > 667)
            space = space + 5;
        make.top.equalTo(mainView.mas_bottom).offset(space);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
    }];
    
    [self addLineToView:secondaryView withDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    

    [self mainButtonWithImageName:@"hp_addgas_2_5" title:@"油卡充值" index:0 action:@selector(actionAddGas:) inContainer:mainView hasBorder:YES];
    [self mainButtonWithImageName:@"hp_violation_2_5" title:@"违章查询" index:1 action:@selector(actionQueryViolation:) inContainer:mainView hasBorder:YES];
    [self mainButtonWithImageName:@"hp_estimate_2_5" title:@"爱车估值" index:2 action:@selector(actionCarEstimate:) inContainer:mainView hasBorder:YES];
    
 
    //洗车 //按钮大小不同图片不同
    NSString * carwashBtnName;
    CGFloat height = 226.0f / 1136.0f * dHeight;
    CGFloat hhh;
    if (dHeight > 667)
    {
        hhh = height + 23;
        carwashBtnName = @"hp_carwash_big_2_5";
    }
    else if (dHeight > 568)
    {
        hhh = height + 15;
        carwashBtnName = @"hp_carwash_mid_2_5";
    }
    else
    {
        hhh = height;
        carwashBtnName = @"hp_carwash_2_5";
    }
    
    CGFloat width = height * 447 / 226;
    UIButton *carwashBtn = [self functionalButtonWithImageName:carwashBtnName action:@selector(actionWashCar:) inContainer:secondaryView hasBorder:NO];
    [carwashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(secondaryView);
        make.width.mas_equalTo(width);
        make.top.equalTo(secondaryView);
        make.height.mas_equalTo(hhh);
    }];
    
    [self addLineToView:carwashBtn withDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsZero];
    [self addLineToView:carwashBtn withDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    
    //洗车 //按钮大小不同图片不同
    NSString * couponBtnName;
    if (dHeight > 667)
    {
        hhh = height + 23;
        couponBtnName = @"hp_coupon_big_2_5";
    }
    else if (dHeight > 568)
    {
        hhh = height + 15;
        couponBtnName = @"hp_coupon_mid_2_5";
    }
    else
    {
        hhh = height;
        couponBtnName = @"hp_coupon_2_5";
    }
    UIButton *couponBtn = [self functionalButtonWithImageName:couponBtnName action:@selector(actionAward:) inContainer:secondaryView hasBorder:NO];
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
    UIButton *insuranceBtn = [self functionalButtonWithImageName:@"hp_insurance_2_5" action:@selector(actionInsurance:) inContainer:secondaryView hasBorder:NO];
    [insuranceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(secondaryView.mas_left);
        make.top.equalTo(carwashBtn.mas_bottom);
        make.width.equalTo(mainView.mas_width).multipliedBy(0.5);
        
        CGFloat height = 256.0f / 1136.0f * dHeight;
        
        CGFloat hhh;
        if (dHeight > 667)
        {
            hhh = height + 23;
        }
        else if (dHeight > 568)
        {
            hhh = height + 15;
        }
        else
        {
            hhh = height;
        }
        make.height.mas_equalTo(height);
    }];
    
    [self addLineToView:insuranceBtn withDirection:CKViewBorderDirectionRight withEdge:UIEdgeInsetsZero];

    //专业救援
    UIButton *rescueBtn = [self functionalButtonWithImageName:@"hp_rescue_2_5" action:@selector(actionRescue:) inContainer:secondaryView hasBorder:NO];
    [rescueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(insuranceBtn.mas_right);
        make.top.equalTo(insuranceBtn);
        make.width.equalTo(insuranceBtn.mas_width);
        make.height.equalTo(insuranceBtn.mas_height).multipliedBy(0.5f);
    }];
    
    [self addLineToView:rescueBtn withDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    
    //申请协办
    UIButton *commissionBtn = [self functionalButtonWithImageName:@"hp_commission_2_5" action:@selector(actionCommission:) inContainer:secondaryView hasBorder:NO];
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
                                        targetVC:self mobBaseEvent:@"rp101-10"];
    
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
    [MobClick event:@"rp101-1"];
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
    
    [[[[sig1 initially:^{
        @strongify(self);
        [self.scrollView.refreshView beginRefreshing];
    }] flattenMap:^RACStream *(AMapReGeocode *regeo) {
        @strongify(self);
        [self.adctrl reloadDataWithForce:YES completed:nil];
        return [self rac_getWeatherInfoWithReGeocode:regeo];
//        RACSignal *sig2 = [self rac_getWeatherInfoWithReGeocode:regeo];
//        RACSignal *sig3 = [self rac_getAdListWithReGeocode:regeo];
//        return [sig2 merge:sig3];
    }] finally:^{
        @strongify(self);
        [self.scrollView.refreshView endRefreshing];
    }] subscribeNext:^(id x) {
        
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

#pragma mark - Action
- (IBAction)actionCallCenter:(id)sender
{
    [MobClick event:@"rp101-2"];
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
}


- (IBAction)actionChooseCity:(id)sender
{
}

- (void)actionWashCar:(id)sender
{
    [MobClick event:@"rp101-3"];
    CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionInsurance:(id)sender
{
    [MobClick event:@"rp101-4"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        UIViewController *vc = [UIStoryboard vcWithId:@"InsuranceVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionRescue:(id)sender
{
    [MobClick event:@"rp101-5"];
    RescureHomeViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescureHomeViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCommission:(id)sender
{
    [MobClick event:@"rp101-6"];
   
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
         CommissonOrderVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissonOrderVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
}

- (void)actionAward:(id)sender
{
    [MobClick event:@"rp101-11"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        CheckAwardViewController * vc = [awardStoryboard instantiateViewControllerWithIdentifier:@"CheckAwardViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)actionAddGas:(id)sender
{
    [MobClick event:@"rp101-12"];
    GasVC *vc = [UIStoryboard vcWithId:@"GasVC" inStoryboard:@"Gas"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionQueryViolation:(id)sender
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        
        ViolationViewController * vc = [violationStoryboard instantiateViewControllerWithIdentifier:@"ViolationViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionCarEstimate:(id)sender
{
    ValuationViewController *vc = [UIStoryboard vcWithId:@"ValuationViewController" inStoryboard:@"Valuation"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Utility
- (UIButton *)functionalButtonWithImageName:(NSString *)imgName action:(SEL)action inContainer:(UIView *)container hasBorder:(BOOL)border
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor whiteColor];
    UIImage *img = [UIImage imageNamed:imgName];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
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
    return btn;
}

- (UIButton *)mainButtonWithImageName:(NSString *)imgName title:(NSString *)title index:(NSInteger)index action:(SEL)action inContainer:(UIView *)container hasBorder:(BOOL)border
{
    UIButton * btn = [self functionalButtonWithImageName:imgName action:action inContainer:container hasBorder:NO];
    UILabel * lb = [[UILabel alloc] init];
    lb.text = title;
    lb.font = [UIFont systemFontOfSize:12];
    lb.textColor = [UIColor colorWithHex:@"#454545" alpha:1.0f];
    [container addSubview:lb];
    
    
    
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



@end
