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
#import "SYPaginator.h"
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

#define WeatherRefreshTimeInterval 60 * 30

static NSInteger rotationIndex = 0;


@interface HomePageVC ()<UIScrollViewDelegate, SYPaginatorViewDataSource, SYPaginatorViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *weatherView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) SYPaginatorView *adView;

@property (nonatomic,strong)IBOutlet UITextField * textFeild;
@end

@implementation HomePageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [gAppMgr loadLastLocationAndWeather];
    [gAppMgr loadLastAdvertiseInfo];
    
    //自动登陆
    [self autoLogin];
    //设置主页的滚动视图
    [self setupScrollView];
    
    [self rotationTableHeaderView];
    
    [self getWeatherInfo];
    [self requestHomePageAd];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupWeatherView:gAppMgr.temperaturepic andTemperature:gAppMgr.temperature andTemperaturetip:gAppMgr.temperaturetip andRestriction:gAppMgr.restriction];
}

- (void)autoLogin
{
    HKLoginModel *loginModel = [[HKLoginModel alloc] init];
    //**********开始自动登录****************
    //该自动登陆为无网络自动登陆，会从上次的本地登陆状态中恢复，不需要联网
    //之后调用的任何需要鉴权的http请求，如果发现上次的登陆状态失效，将会自动触发后台刷新token和重新登陆的机制。
    //再次登陆成功后会自动重发这个http请求，不需要人工干预
    [[loginModel rac_autoLoginWithoutNetworking] subscribeNext:^(NSString *account) {
        [gAppMgr resetWithAccount:account];
        
        // 获取用户车辆
        [[gAppMgr.myUser rac_requestGetUserCar] subscribeNext:^(id x) {
            
        }];
    }];
}

- (void)setupScrollView
{
    //天气视图
    [self.weatherView removeFromSuperview];
    [self.scrollView addSubview:self.weatherView];
    @weakify(self);
    [self.weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    UIView *container = [UIView new];
    [self.scrollView addSubview:container];
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
    @weakify(btn1);
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn1);
        make.top.equalTo(self.adView.mas_bottom).offset(11);
        make.left.equalTo(container).offset(11);
        make.right.equalTo(container).offset(-11);
        make.height.equalTo(btn1.mas_width).multipliedBy(212.0/590);
    }];
    //保险
    UIButton *btn2 = [self functionalButtonWithImageName:@"hp_insurance" action:@selector(actionInsurance:) inContainer:container];
    @weakify(btn2);
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn2);
        make.left.equalTo(btn1.mas_left);
        make.top.equalTo(btn1.mas_bottom).offset(7);
        make.width.equalTo(btn1.mas_width).multipliedBy(0.5);
        make.height.equalTo(btn2.mas_width).multipliedBy(344.0f/346.0f);
    }];
    //专业救援
    UIButton *btn3 = [self functionalButtonWithImageName:@"hp_rescue" action:@selector(actionRescue:) inContainer:container];
    @weakify(btn3);
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn3);
        make.left.equalTo(btn2.mas_right).offset(7);
        make.right.equalTo(btn1.mas_right);
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
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = width*360.0/1242.0;
    SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    adView.delegate = self;
    adView.dataSource = self;
    adView.pageGapWidth = 0;
    [container addSubview:adView];
    self.adView = adView;
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container);
        make.right.equalTo(container);
        make.top.equalTo(container);
        make.height.mas_equalTo(height);
    }];
    self.adView.currentPageIndex = 0;
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
        UIBarButtonItem *cityBtn =
        [[UIBarButtonItem alloc] initWithTitle:city style:UIBarButtonItemStyleDone target:self action:nil];
        self.navigationItem.leftBarButtonItem = cityBtn;
    }
    else
    {
        UIBarButtonItem *retrybtn =
        [[UIBarButtonItem alloc] initWithTitle:@"点击重试" style:UIBarButtonItemStyleDone target:self action:@selector(getWeatherInfo)];
        self.navigationItem.leftBarButtonItem = retrybtn;
    }
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
    
    NSArray * tArray = [picName componentsSeparatedByString:@"/"];
    if (tArray.count)
    {
        picName = [tArray lastObject];
    }
    weatherImage.image = [UIImage imageNamed:picName];
    tempLb.text = temp;
    restrictionLb.text = restriction;
    tipLb.text = tip;
}


#pragma mark - Action
- (IBAction)actionCallCenter:(id)sender
{
    AuthByVcodeOp * op = [AuthByVcodeOp new];
    op.skey = [[self.textFeild.text md5] substringToIndex:10];
    op.token = gNetworkMgr.token;
    [[op rac_postRequest] subscribeNext:^(AuthByVcodeOp * op) {
        
        gNetworkMgr.skey = op.skey;

    }];
}

- (IBAction)actionChooseCity:(id)sender
{
    
}

- (void)actionWashCar:(id)sender
{
    CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
    vc.type = 1 ;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionInsurance:(id)sender
{
    UIViewController *vc = [UIStoryboard vcWithId:@"InsuranceVC" inStoryboard:@"Insurance"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionRescue:(id)sender
{
    UIViewController *vc = [UIStoryboard vcWithId:@"RescueViewController" inStoryboard:@"Main"];
//    RescueViewController * vc = [otherStoryboard instantiateViewControllerWithIdentifier:@"RescueViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCommission:(id)sender
{
    ServiceViewController * vc = [otherStoryboard instantiateViewControllerWithIdentifier:@"ServiceViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rotationTableHeaderView
{
    //    每隔6秒滚动宣传栏
    [[RACSignal interval:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        
        /// 重置i
        NSInteger count = gAppMgr.homepageAdvertiseArray.count;
        if(count == 0 || count == 1)
        {
            return ;
        }
        rotationIndex = rotationIndex == count - 1 ? 0 : rotationIndex + 1;
        [self.adView setCurrentPageIndex:rotationIndex animated:YES];
    }];
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


- (void)getWeatherInfo
{
    [[[[gMapHelper rac_getInvertGeoInfo] take:1] initially:^{
        
        [self setupNavigationLeftBar:@"定位中..."];
    }] subscribeNext:^(AMapReGeocode * getInfo) {
        
        [self setupNavigationLeftBar:getInfo.addressComponent.city];
        [self requestWeather:getInfo.addressComponent.province
                     andCity:getInfo.addressComponent.city
                 andDistrict:getInfo.addressComponent.district];
        
        /// 内存缓存地址信息
        gAppMgr.province = getInfo.addressComponent.province;
        gAppMgr.city = getInfo.addressComponent.city;
        gAppMgr.district = getInfo.addressComponent.district;
        /// 硬盘缓存地址信息
        [gAppMgr saveInfo:getInfo.addressComponent.province forKey:Province];
        [gAppMgr saveInfo:getInfo.addressComponent.city forKey:City];
        [gAppMgr saveInfo:getInfo.addressComponent.district forKey:District];
        NSString * dateStr = [[NSDate date] dateFormatForDT15];
        [gAppMgr saveInfo:dateStr forKey:LastLocationTime];
        
    } error:^(NSError *error) {
        
        [self setupNavigationLeftBar:nil];
        switch (error.code) {
            case kCLErrorDenied:
            {
                if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
                {
                    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置进行操作" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置", nil];
                    
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
                    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置进行操作" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    
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

    }];
}

- (void)requestWeather:(NSString *)p andCity:(NSString *)c andDistrict:(NSString *)d
{
    GetSystemTipsOp * op = [GetSystemTipsOp operation];
    op.province = p;
    op.city = c;
    op.district = d;
    [[[op rac_postRequest] initially:^{
        
        
    }] subscribeNext:^(GetSystemTipsOp * op) {
        
        if(op.rsp_code == 0)
        {
            [self setupWeatherView:op.rsp_temperaturepic andTemperature:op.rsp_temperature andTemperaturetip:op.rsp_temperaturetip andRestriction:op.rsp_restriction];
            
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
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"天气接口OK，但是rspcode!=0..."];
        }
    } error:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"天气获取失败..."];
    }];
}


- (void)requestHomePageAd
{
    GetSystemPromotionOp * op = [GetSystemPromotionOp operation];
    op.type = AdvertisementHomePage;
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetSystemPromotionOp * op) {
        
        if (op.rsp_code == 0)
        {
            gAppMgr.homepageAdvertiseArray = op.rsp_advertisementArray;
            
            [self.adView reloadData];
            self.adView.currentPageIndex = 0;
            
            [gAppMgr saveInfo:op.rsp_advertisementArray forKey:HomepageAdvertise];
        }
    } error:^(NSError *error) {
        
    }];
}



#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    NSInteger ii = gAppMgr.homepageAdvertiseArray.count ? gAppMgr.homepageAdvertiseArray.count : 1;
    return ii ;
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    SYPageView *pageView = [paginatorView dequeueReusablePageWithIdentifier:@"pageView"];
    if (!pageView) {
        pageView = [[SYPageView alloc] initWithReuseIdentifier:@"pageView"];
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:pageView.bounds];
        imgV.autoresizingMask = UIViewAutoresizingFlexibleAll;
        imgV.tag = 1001;
        [pageView addSubview:imgV];
    }
    UIImageView *imgV = (UIImageView *)[pageView viewWithTag:1001];
    HKAdvertisement * ad = [gAppMgr.homepageAdvertiseArray safetyObjectAtIndex:pageIndex];
//    imgV.image = [UIImage imageNamed:@"hp_bottom"];
    [[gMediaMgr rac_getPictureForUrl:ad.adPic withDefaultPic:@"hp_bottom"] subscribeNext:^(id x) {
            imgV.image = x;
    }];
    
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    
}


@end
