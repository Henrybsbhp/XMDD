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
#import "AuthByVcodeOp.h"
#import "NSString+MD5.h"
#import "UpdatePwdOp.h"
#import "GetShopByDistanceOp.h"
#import "CarWashTableVC.h"
#import "RescueViewController.h"
#import "HKLoginModel.h"
#import "GetSystemTipsOp.h"
#import "GetSystemPromotionOp.h"
#import "ServiceViewController.h"
#import "JTUser.h"
#import "WebVC.h"
#import "SocialShareViewController.h"
#import "RescureViewController.h"
#import "CommissionViewController.h"
#import "UIImage+Utilities.h"
#import "CheckUserAwardOp.h"
#import "GainAwardViewController.h"
#import "GainedViewController.h"
#import "WelcomeViewController.h"
#import "CheckAwardViewController.h"
#import "ADViewController.h"
#import "CollectionChooseVC.h"
#import "InsuranceDetailPlanVC.h"

#import "PaymentSuccessVC.h"

#define WeatherRefreshTimeInterval 60 * 30

@interface HomePageVC ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *weatherView;
@property (nonatomic, strong) UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) ADViewController *adctrl;
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

    [gAppMgr loadLastLocationAndWeather];
    [gAdMgr loadLastAdvertiseInfo:AdvertisementHomePage];
    [gAdMgr loadLastAdvertiseInfo:AdvertisementCarWash];
    
    //自动登录
    [self autoLogin];
    //设置主页的滚动视图
    [self setupScrollView];
    [self setupWeatherView];
//    [self rotationTableHeaderView];
    
    [self.scrollView.refreshView addTarget:self action:@selector(reloadDatasource) forControlEvents:UIControlEventValueChanged];
    CKAsyncMainQueue(^{
        [self reloadDatasource];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CKAsyncMainQueue(^{
        CGSize size = [self.containerView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, ceil(size.height));
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
    //天气视图
    [self.weatherView removeFromSuperview];
    [self.scrollView addSubview:self.weatherView];
    
    CGFloat deviceWidth = gAppMgr.deviceInfo.screenSize.width;

    @weakify(self);
    [self.weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:container];
    self.containerView = container;
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.weatherView.mas_bottom);
        make.left.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    //广告
    [self setupADViewInContainer:container];

    //洗车
    UIButton *btn1 = [self functionalButtonWithImageName:@"hp_washcar" action:@selector(actionWashCar:) inContainer:container];
    //抢红包
    UIButton *btn5 = [self functionalButtonWithImageName:@"hp_award" action:@selector(actionAward:) inContainer:container];
    
    [btn5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.adctrl.adView.mas_bottom).offset(11);
        make.right.equalTo(container).offset(-11);
        
        if (deviceWidth <= 320)
        {
            make.width.equalTo(container.mas_width).multipliedBy(180.0/640);
            make.height.equalTo(container.mas_width).multipliedBy(212.0/640);
        }
        else
        {
            make.width.equalTo(container.mas_width).multipliedBy(190.0/640);
            make.height.equalTo(container.mas_width).multipliedBy(230.0/640);
        }
    }];
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.adctrl.adView.mas_bottom).offset(11);
        make.left.equalTo(container).offset(11);
        make.right.equalTo(btn5.mas_left).offset(-7);
        make.height.equalTo(btn5);
    }];
 
    //保险
    UIButton *btn2 = [self functionalButtonWithImageName:@"hp_insurance" action:@selector(actionInsurance:) inContainer:container];
    @weakify(btn2);
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn2);
        make.left.equalTo(btn1.mas_left);
        make.right.equalTo(container.mas_centerX);
        make.top.equalTo(btn1.mas_bottom).offset(7);
//        make.width.equalTo(btn1.mas_width).multipliedBy(0.5);
        make.height.equalTo(btn2.mas_width).multipliedBy(344.0f/346.0f);
    }];
    //专业救援
    UIButton *btn3 = [self functionalButtonWithImageName:@"hp_rescue" action:@selector(actionRescue:) inContainer:container];
    @weakify(btn3);
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn3);
        make.left.equalTo(btn2.mas_right).offset(7);
        make.right.equalTo(container.mas_right).offset(-11);
        make.top.equalTo(btn1.mas_bottom).offset(7);
        make.height.equalTo(btn3.mas_width).multipliedBy(165.0f/332.0f);
    }];
    //申请代办
    UIButton *btn4 = [self functionalButtonWithImageName:@"hp_commission" action:@selector(actionCommission:) inContainer:container];
    @weakify(btn4);
    [btn4 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn4);
        make.left.equalTo(btn3);
        make.right.equalTo(btn3);
        make.bottom.equalTo(btn2);
        make.height.equalTo(btn4.mas_width).multipliedBy(165.0f/332.0f);
    }];
    
    //底部
    [self setupBottomViewWithUpper:btn4];
    
    [container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btn4).offset(47+2);
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
    restrictionLb.text = restriction;
    
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
        [self setupNavigationLeftBar:regeo.addressComponent.city];
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
    op.city = regeo.addressComponent.city;
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
//    [MobClick event:@"rp101-2"];
//    NSString * number = @"4007111111";
//    [gPhoneHelper makePhone:number andInfo:@"客服电话：4007-111-111"];
    
    PaymentSuccessVC * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"PaymentSuccessVC"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)actionChooseCity:(id)sender
{
}

- (void)actionWashCar:(id)sender
{
    [MobClick event:@"rp101-3"];
    CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
    vc.type = 1 ;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionInsurance:(id)sender
{
    [MobClick event:@"rp101-4"];
    UIViewController *vc = [UIStoryboard vcWithId:@"InsuranceVC" inStoryboard:@"Insurance"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionRescue:(id)sender
{
    [MobClick event:@"rp101-5"];
    RescureViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescureViewController"];
    vc.url = @"http://www.xiaomadada.com/apphtml/jiuyuan.html";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCommission:(id)sender
{
    [MobClick event:@"rp101-6"];
    CommissionViewController *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionViewController"];
    vc.url = @"http://www.xiaomadada.com/apphtml/daiban.html";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionAward:(id)sender
{
    [MobClick event:@"rp101-11"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        CheckAwardViewController * vc = [awardStoryboard instantiateViewControllerWithIdentifier:@"CheckAwardViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Utility
- (UIButton *)functionalButtonWithImageName:(NSString *)imgName action:(SEL)action inContainer:(UIView *)container
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor whiteColor];
    UIImage *img = [UIImage imageNamed:imgName];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor colorWithWhite:0.84 alpha:1.0].CGColor;
    btn.layer.borderWidth = 1.0;
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    [container addSubview:btn];
    return btn;
}

- (void)setupLineSpace:(UILabel *)label withText:(NSString *)text
{
    if (IOSVersionGreaterThanOrEqualTo(@"7.0")) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:5];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
        label.attributedText = attributedString;
    }
    else {
        label.text = text;
    }
}

@end
