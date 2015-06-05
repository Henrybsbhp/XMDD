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
#import <AFNetworking2-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>
#import "JTUser.h"
#import "WebVC.h"
#import "AdvertisementManager.h"
#import "SocialShareViewController.h"
#import "RescureViewController.h"
#import "CommissionViewController.h"
#import "UIImage+Utilities.h"

#define WeatherRefreshTimeInterval 60 * 30

static NSInteger rotationIndex = 0;


@interface HomePageVC ()<UIScrollViewDelegate, SYPaginatorViewDataSource, SYPaginatorViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *weatherView;
@property (nonatomic, strong) UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) SYPaginatorView *adView;

@property (nonatomic,strong)IBOutlet UITextField * textFeild;
@end

@implementation HomePageVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp101"];
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
//    //设置主页的滚动视图
    [self setupScrollView];
    [self setupWeatherView];
    [self rotationTableHeaderView];
    
    [self.scrollView.refreshView addTarget:self action:@selector(reloadDatasource) forControlEvents:UIControlEventValueChanged];
    [self reloadDatasource];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CKAsyncMainQueue(^{
        CGSize size = [self.containerView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, ceil(size.height));
    });
//    [self setupWeatherView:gAppMgr.temperaturepic andTemperature:gAppMgr.temperature andTemperaturetip:gAppMgr.temperaturetip andRestriction:gAppMgr.restriction];
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
        
        // 获取用户车辆
//        [[gAppMgr.myUser.carModel rac_updateModel] subscribeNext:^(id x) {
//            
//        }];
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
        [[UIBarButtonItem alloc] initWithTitle:@"定位失败" style:UIBarButtonItemStyleDone target:self action:@selector(rac_getWeatherInfo)];
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
    
    RAC(weatherImage, image) = [gAppMgr.mediaMgr rac_getPictureForUrl:picName withType:ImageURLTypeOrigin defaultPic:nil errorPic:nil];
    
    tempLb.text = temp;
    restrictionLb.text = restriction;
    tipLb.text = tip;
    
    if(tipLb.text.length)
    {
        [self setupLineSpace:tipLb];
    }
}

- (void)setupWeatherView
{
    UIImageView * weatherImage = (UIImageView *)[self.weatherView searchViewWithTag:20201];
    UILabel * tempLb = (UILabel *)[self.weatherView searchViewWithTag:20202];
    UILabel * restrictionLb = (UILabel *)[self.weatherView searchViewWithTag:20204];
    UILabel * tipLb = (UILabel *)[self.weatherView searchViewWithTag:20206];
    
    RAC(tempLb, text) = RACObserve(gAppMgr, temperature);
    RAC(restrictionLb, text) = RACObserve(gAppMgr, restriction);
    
    [RACObserve(gAppMgr, temperaturetip) subscribeNext:^(id x) {
        tipLb.text = x;
        
        if(tipLb.text.length)
        {
            [self setupLineSpace:tipLb];
        }
    }];
    
    NSString * picName = @"";
    NSArray * tArray = [gAppMgr.temperaturepic componentsSeparatedByString:@"/"];
    if (tArray.count)
    {
        picName = [tArray lastObject];
    }
    weatherImage.image = [UIImage imageNamed:picName];
    
    RAC(weatherImage, image) = [[RACObserve(gAppMgr, temperaturepic)distinctUntilChanged] map:^id(id value) {

        NSString * picName = [[value componentsSeparatedByString:@"/"] lastObject];
        return [UIImage imageNamed:picName];
    }];
}

- (void)reloadDatasource
{
    @weakify(self);
    [[[[[self rac_getWeatherInfo] merge:[self rac_requestHomePageAd]] initially:^{
      
        @strongify(self);
        [self.scrollView.refreshView beginRefreshing];
    }] finally:^{
        
        @strongify(self);
        [self.scrollView.refreshView endRefreshing];
    }] subscribeNext:^(id x) {
        
    }];
}

#pragma mark - Action
- (IBAction)actionCallCenter:(id)sender
{
    [MobClick event:@"rp101-2"];
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"客服电话"];
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
    vc.urlStr = @"http://www.xiaomadada.com/apphtml/jiuyuan.html";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCommission:(id)sender
{
    [MobClick event:@"rp101-6"];
    CommissionViewController *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionViewController"];
    vc.urlStr = @"http://www.xiaomadada.com/apphtml/daiban.html";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rotationTableHeaderView
{
    //    每隔6秒滚动宣传栏
    RACDisposable *dis = [[gAdMgr rac_scrollTimerSignal] subscribeNext:^(id x) {
        
        NSInteger index = self.adView.currentPageIndex+1;
        if (index >= gAdMgr.homepageAdvertiseArray.count) {
            index = 0;
        }
        [self.adView setCurrentPageIndex:index animated:YES];
    }];
    [[self rac_deallocDisposable] addDisposable:dis];
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

- (void)setupLineSpace:(UILabel *)label
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:5];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [label.text length])];
    label.attributedText = attributedString;
    [label sizeToFit];
}


- (RACSignal *)rac_getWeatherInfo
{
    
    return [[[[[gMapHelper rac_getInvertGeoInfo] take:1] initially:^{
        
        [self setupNavigationLeftBar:@"定位中..."];
    }] doNext:^(AMapReGeocode * getInfo) {
        
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
        
    }] doError:^(NSError *error) {
        
        [self setupNavigationLeftBar:nil];
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
//            [self setupWeatherView:op.rsp_temperaturepic andTemperature:op.rsp_temperature andTemperaturetip:op.rsp_temperaturetip andRestriction:op.rsp_restriction];
            
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
            [gToast showError:@"天气获取失败"];
        }
    } error:^(NSError *error) {
        
        [gToast showError:@"天气获取失败"];
    }];
}


- (RACSignal *)rac_requestHomePageAd
{
    return [[gAdMgr rac_getAdvertisement:AdvertisementHomePage] doNext:^(NSArray * array) {
        
        [self.adView reloadData];
        self.adView.currentPageIndex = 0;
    }];
//
//    [[gAdMgr rac_getAdvertisement:AdvertisementCarWash] subscribeNext:^(NSArray * array) {
//        
//
//    }];
}



#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    NSInteger ii = gAdMgr.homepageAdvertiseArray.count ? gAdMgr.homepageAdvertiseArray.count : 1;
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
    HKAdvertisement * ad = [gAdMgr.homepageAdvertiseArray safetyObjectAtIndex:pageIndex];
//    [[[gMediaMgr rac_getPictureForUrl:ad.adPic withDefaultPic:@"hp_bottom"] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
//        
//        imgV.image = x;
//    }];
    [[gMediaMgr rac_getPictureForUrl:ad.adPic withType:ImageURLTypeMedium defaultPic:@"ad_default" errorPic:@"ad_default"]
     subscribeNext:^(id x) {
        UIImage * image = x;
        if (image.size.width > (imgV.frame.size.width * 2)) {
            image = [image compressImageWithPointSize:imgV.frame.size];
        }
        imgV.image = image;
    }];
//
    UITapGestureRecognizer * gesture = imgV.customObject;
    if (!gesture)
    {
        UITapGestureRecognizer *ge = [[UITapGestureRecognizer alloc] init];
        [imgV addGestureRecognizer:ge];
        imgV.userInteractionEnabled = YES;
        imgV.customObject = ge;
    }
    gesture = imgV.customObject;
    [[[gesture rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        NSString * eventstr = [NSString stringWithFormat:@"rp101-10.%ld", pageIndex];
        [MobClick endEvent:eventstr];
        if (ad.adLink.length)
        {
            WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
            vc.title = @"广告";
            vc.url = ad.adLink;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
            vc.title = @"小马达达";
            vc.url = XIAMMAWEB;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    
    
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    
}


@end
