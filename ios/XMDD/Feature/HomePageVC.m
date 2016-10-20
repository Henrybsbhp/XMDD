//
//  HomePageVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.


#import "HomePageVC.h"
#import "UIImage+Utilities.h"
#import "UIView+Layer.h"
#import "UIView+HKLine.h"
#import "NSString+RectSize.h"
#import "GetSystemTipsOp.h"
#import "GetSystemHomeModuleOp.h"
#import "GetSystemHomeModuleNoLoginOp.h"

#import "HKLoginModel.h"
#import "MyCarStore.h"
#import "GuideStore.h"
#import "PasteboardModel.h"
#import "AdListData.h"
#import "HomePageModuleModel.h"

#import "ADViewController.h"
#import "HomeNewbieGuideVC.h"
#import "HomeSuspendedAdVC.h"

#import "TTTAttributedLabel.h"

#define WeatherRefreshTimeInterval 60 * 30
#define KWeatherLinkRange @"weatherLinkRange"
#define KWeatherBigFontRange @"weatherBigFontRange"

@interface HomePageVC ()<UIScrollViewDelegate,TTTAttributedLabelDelegate>

@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *weatherView;

@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, strong) ADViewController *secondAdCtrl;

@property (nonatomic, strong)UIView *mainItemView;
@property (nonatomic, strong)UIView *secondaryItemView;
@property (nonatomic, strong)UIView *containerView;
@property (nonatomic, strong)NSMutableArray * linesArray;

@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) GuideStore *guideStore;
@property (nonatomic, strong) HomePageModuleModel * moduleModel;

/// 当前页面是否是homePageVC
@property (nonatomic, assign) BOOL isViewAppearing;
/// 是否展示广告
@property (nonatomic, assign) BOOL isShowSuspendedAd;
// 九宫格按钮的dispoable数据，控制点击事件释放
@property (nonatomic, strong)NSMutableArray * disposableArray;

/// 地理位置信息信号
@property (nonatomic, strong)RACSignal * regeocodeSignal;

@end


@implementation HomePageVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.userInteractionEnabled = NO;
    
    //读取上次首页元素信息
    [gAppMgr loadLastHomePicInfo];
    //读取上次首页广告和洗车广告
    [gAdMgr loadLastAdvertiseInfo:AdvertisementHomePage];
    [gAdMgr loadLastAdvertiseInfo:AdvertisementCarWash];
    
    //自动登录(含粘贴板监测)
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isViewAppearing = YES;
    [self.scrollView restartRefreshViewAnimatingWhenRefreshing];
    
    [self showSuspendedAdIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewAppearing = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.userInteractionEnabled = YES;
    CKAsyncMainQueue(^{
        CGSize size = [self.containerView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, ceil(size.height));
        
        [self showNewbieGuideAlertIfNeeded];
    });
}


#pragma mark - Setup - UI
- (void)setupScrollView
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
    container.backgroundColor = [UIColor colorWithHex:@"#f7f7f8" alpha:1.0f];
    [self.scrollView addSubview:container];
    self.containerView = container;
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    //广告
    [self setupADViewInContainer:container];
    
    //天气
    [self setupWeatherViewInContainer:container];
    
    // 九宫格区域
    UIView * squaresView = [self setupSquaresViewInContainer:container];
    
    // 九宫格下边的广告
    [self setupSecondADViewInContainer:container withSquaresView:squaresView];
}

- (void)setupWeatherViewInContainer:(UIView *)containerView
{
    //天气视图
    self.weatherView.backgroundColor = [UIColor whiteColor];
    [self.weatherView removeFromSuperview];
    [containerView addSubview:self.weatherView];
    
    @weakify(self);
    [self.weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.adctrl.adView.mas_bottom);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        
        make.height.mas_equalTo(@(54));
    }];
}

- (UIView *)setupSquaresViewInContainer:(UIView *)container
{
    CGFloat deviceWidth = gAppMgr.deviceInfo.screenSize.width;
    ///，长宽比 750 ：612
    CGFloat squaresHeight = 612.0f / 750.0f * deviceWidth;
    if (gAppMgr.deviceInfo.screenSize.height < 568)
        squaresHeight = squaresHeight; //4s 480
    else if (gAppMgr.deviceInfo.screenSize.height < 667)
        squaresHeight = squaresHeight - 15; // 5,5s,568
    else if (gAppMgr.deviceInfo.screenSize.height < 736)
        squaresHeight = squaresHeight; // 6,667
    else if (gAppMgr.deviceInfo.screenSize.height == 736)
        squaresHeight = squaresHeight + 15; // 6p,736
    UIView * squaresView = [[UIView alloc] init];
    squaresView.tag = 101;
    squaresView.backgroundColor = [UIColor whiteColor];
    [container addSubview:squaresView];
    [squaresView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.weatherView.mas_bottom);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.height.mas_equalTo(@(squaresHeight));
    }];
    
    // 设置九宫格内部数据
    [self setupSquaresView:squaresView withHeight:squaresHeight];
    
    //9宫格加边框
    [squaresView drawLineWithDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsMake(0,18,0,18)];
    
    return squaresView;
}

- (void)setupADViewInContainer:(UIView *)container
{
    self.adctrl = [ADViewController vcWithADType:AdvertisementHomePage boundsWidth:self.view.frame.size.width
                                        targetVC:self mobBaseEvent:@"rp101_10" mobBaseEventDict:nil];
    
    CGFloat height = floor(self.adctrl.adView.frame.size.height);
    [container addSubview:self.adctrl.adView];
    [self.adctrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container);
        make.right.equalTo(container);
        make.top.equalTo(container);
        make.height.mas_equalTo(height);
    }];
}

- (void)setupSecondADViewInContainer:(UIView *)container  withSquaresView:(UIView *)squaresView
{
    self.secondAdCtrl = [ADViewController vcWithADType:AdvertisementHomePageBottom boundsWidth:self.view.frame.size.width
                                              targetVC:self mobBaseEvent:@"shouye" mobBaseEventDict:@{@"shouye":@"shouye0002"}];
    
    [container addSubview:self.secondAdCtrl.adView];
    [self.secondAdCtrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        CGFloat space = 12;
        CGFloat ratio = 152 / 750.0;
        CGFloat height = ratio * gAppMgr.deviceInfo.screenSize.width;
        if (gAppMgr.deviceInfo.screenSize.height >= 736)
        {
            height = height + 2;
        }
        make.left.equalTo(container);
        make.right.equalTo(container);
        make.top.equalTo(squaresView.mas_bottom).offset(space);
        make.height.mas_equalTo(height);
    }];
    
    [container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.secondAdCtrl.adView);
    }];
}


- (void)setupNavigationLeftBar:(NSString *)city
{
    if (city.length)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //设置图片
        UIImage *imageForButton = [UIImage imageNamed:@"hp_location_300"];
        [button setImage:imageForButton forState:UIControlStateNormal];
        
        CGSize size = [city labelSizeWithWidth:9999 font:[UIFont boldSystemFontOfSize:15]];
        [button setTitle:city forState:UIControlStateNormal];
        [button setTitleColor:kDefTintColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        button.frame = CGRectMake(0, 0 , size.width + 20, 20);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        UIBarButtonItem *cityBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
        cityBtn.tintColor = kDefTintColor;
        self.navigationItem.leftBarButtonItem = cityBtn;
    }
    else
    {
        UIBarButtonItem *retrybtn = [[UIBarButtonItem alloc] initWithTitle:@"定位失败" style:UIBarButtonItemStyleDone
                                                                    target:self action:@selector(retryGetLocationInfo)];
        self.navigationItem.leftBarButtonItem = retrybtn;
    }
}


- (void)setupWeatherView
{
    UIImageView * weatherImage = (UIImageView *)[self.weatherView searchViewWithTag:20201];
    
    TTTAttributedLabel * tempLb = (TTTAttributedLabel *)[self.weatherView searchViewWithTag:20202];
    tempLb.numberOfLines = 2;
    tempLb.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width;
    tempLb.delegate = self;
    UILabel * restrictionLb = (UILabel *)[self.weatherView searchViewWithTag:20204];
    UIView *rightContainerV = (UIView *)[self.weatherView searchViewWithTag:20200];

    
    //限行信息
    [[RACObserve(gAppMgr, restriction) distinctUntilChanged] subscribeNext:^(NSString *text) {
        rightContainerV.hidden = text.length == 0;
        restrictionLb.text = text;
    }];
    
    // 天气信息
    [RACObserve(gAppMgr, temperatureAndTip) subscribeNext:^(NSString *text) {
        
        if (!text)
            return ;
        [self setupTTTLabel:tempLb withContent:text];
    }];
    
    // 天气图片
    [[RACObserve(gAppMgr, temperaturepic)distinctUntilChanged] subscribeNext:^(id x) {
        NSString * picName = [[x componentsSeparatedByString:@"/"] lastObject];
        weatherImage.image = [UIImage imageNamed:picName];
    }];
}

- (void)setupSquaresView:(UIView *)containView withHeight:(CGFloat)height
{
    CGFloat squaresHeight = height;
    CGFloat squqresWidth = gAppMgr.deviceInfo.screenSize.width;
    
    self.moduleModel.moduleArray = gAppMgr.homePicModel.homeItemArray;
    self.moduleModel.numOfColumn = 4;
    
    [self.moduleModel setupSquaresViewWithContainView:containView andItemWith:squqresWidth/4.0 andItemHeigth:squaresHeight/3.0];
}

- (void)setupTTTLabel:(TTTAttributedLabel *)label withContent:(NSString *)text
{
    NSRange linkRange = [text.customInfo[KWeatherLinkRange] isKindOfClass:[NSValue class]] ? [text.customInfo[KWeatherLinkRange] rangeValue]: NSMakeRange(0, 0);
    NSRange bigFontRange = [text.customInfo[KWeatherBigFontRange] isKindOfClass:[NSValue class]] ? [text.customInfo[KWeatherBigFontRange] rangeValue]: NSMakeRange(0, 0);
    
    NSMutableString *mutableString = [NSMutableString stringWithString:text];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 7;
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:mutableString
                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10],
                                                                              NSForegroundColorAttributeName: kGrayTextColor,
                                                                              NSParagraphStyleAttributeName: ps}];
    if (bigFontRange.length)
        [attstr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:bigFontRange];
    
    label.attributedText = attstr;
    [label setLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],
                               NSForegroundColorAttributeName: HEXCOLOR(@"#007aff")}];
    [label setActiveLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],
                                     NSForegroundColorAttributeName: kGrayTextColor}];
    [label addLinkToURL:[NSURL URLWithString:@""] withRange:linkRange];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
     if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
     {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
     }
}



#pragma mark - Setup Store
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
    if (!self.guideStore.shouldDisablePopupAd && self.isViewAppearing && !self.isShowSuspendedAd && ![[UIPasteboard generalPasteboard].string hasPrefix:XMINSPrefix]) {
        
        self.isShowSuspendedAd = YES;
        
        @weakify(self);
        RACSignal * adSignal = [gAdMgr rac_getAdvertisement:AdvertisementAlert];
        [[adSignal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *ads) {
            
            @strongify(self);
            NSMutableArray * mutableArr = [[NSMutableArray alloc] init];
            for (int i = 0; i < ads.count; i ++) {
                HKAdvertisement * adDic = ads[i];
                //广告是否已经看过
                if (![AdListData checkAdAlreadyAppeard:adDic]) {
                    [mutableArr addObject:adDic];
                }
            }
            //若弹出抢登登录框，则不弹出广告
            if (!gAppDelegate.errorModel.alertView && mutableArr.count > 0) {
                
                [HomeSuspendedAdVC presentInTargetVC:self withAdList:mutableArr];
            }
        }];
    }
}


#pragma mark - Action
- (IBAction)actionCallService:(id)sender {
    [MobClick event:@"rp101_2"];
    
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}


#pragma mark - Utility
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
        
        [self setupJSPatch];
    } error:^(NSError *error) {
        gAppDelegate.pushMgr.notifyQueue.running = YES;
        gAppDelegate.openUrlQueue.running = YES;
        //未登录
        [self checkPasteboardModel];
        
        [self setupJSPatch];
    }];
}

- (void)checkPasteboardModel
{
    //设置口令弹框取消按钮的block
    [gAppDelegate.pasteboardoModel setCancelClickBlock:^(id x) {
        [UIPasteboard generalPasteboard].string = @"";
        [self showSuspendedAdIfNeeded];
    }];
    //设置口令弹框下一页
    [gAppDelegate.pasteboardoModel setNextClickBlock:^(id x) {
        if ([[UIPasteboard generalPasteboard].string hasPrefix:XMINSPrefix] && [MZFormSheetController formSheetControllersStack]) {
            MZFormSheetController * mzVC = [[MZFormSheetController formSheetControllersStack] safetyObjectAtIndex:0];
            [mzVC dismissAnimated:NO completionHandler:nil];
        }
        self.isShowSuspendedAd = NO;
    }];
    [gAppDelegate.pasteboardoModel checkPasteboard];
}

- (void)retryGetLocationInfo
{
    [MobClick event:@"rp101_1"];
    
    [self reloadDatasource];
}

- (void)reloadDatasource
{
    [[RACObserve(gMapHelper, addrComponent) distinctUntilChanged] subscribeNext:^(HKAddressComponent * addComponent) {
        
        NSString * city;
        city = addComponent.city.length ? addComponent.city : addComponent.province;
        [self setupNavigationLeftBar:city];
    }];
    
    
    @weakify(self);
    RACSignal *sig1 = [[[[[gMapHelper rac_getUserLocationAndInvertGeoInfoWithAccuracy:kCLLocationAccuracyKilometer] take:1] initially:^{
        @strongify(self);
        [self setupNavigationLeftBar:@"定位中..."];
    }] doError:^(NSError *error) {
        
        @strongify(self);
        [self setupNavigationLeftBar:nil];
        [self handleLocationError:error];
    }] map:^id(RACTuple * tuple) {
        
        return tuple.second;
    }];
    
    self.regeocodeSignal = sig1;
    
    // 获取天气信息
    [[[[[sig1 initially:^{
        @strongify(self);
        [self.scrollView.refreshView beginRefreshing];
    }] catch:^RACSignal *(NSError *error) {

        
        return [RACSignal error:error];
    }] flattenMap:^RACStream *(AMapLocationReGeocode * code) {
        
        @strongify(self);
        return [self rac_getWeatherInfoWithReGeocode:code];
    }]  finally:^{
        
        @strongify(self);
        //失败也要获取广告
        [self.adctrl reloadDataWithForce:YES completed:nil];
        [self.secondAdCtrl reloadDataWithForce:YES completed:nil];
        [self.scrollView.refreshView endRefreshing];
    }] subscribeNext:^(id x) {
        
    }];

    
    /// 九宫格数据
    RACSignal * userSignal = [RACObserve(gAppMgr, myUser) distinctUntilChanged];
    
    RACSignal * combineSignal = [RACSignal combineLatest:@[sig1,userSignal] reduce:^(AMapLocationReGeocode *regeo, JTUser * user) {
        return RACTuplePack(regeo,user);
    }];
    
    RACSignal * homeSubmudleSignal = [combineSignal flattenMap:^RACStream *(RACTuple *tuple) {
        
        AMapLocationReGeocode *regeo = tuple.first;
        JTUser * user = tuple.second;
        return [self rac_requestHomeSubmuduleWithUser:user andReGeocode:regeo];
    }];
    
    [homeSubmudleSignal subscribeNext:^(GetSystemHomeModuleOp * op) {
        
        gAppMgr.homePicModel = [gAppMgr.homePicModel analyzeHomePicModel:op.homeModel];
        [gAppMgr saveHomePicInfo];
        
        UIView *containView = (UIView *)[self.view searchViewWithTag:101];
        self.moduleModel.moduleArray = gAppMgr.homePicModel.homeItemArray;
        [self.moduleModel refreshSquareView:containView];
        

        gAppMgr.huzhuTabFlag = op.huzhuTabFlag;
        [gAppMgr saveMutualPlanTabAppear:op.huzhuTabFlag];
            
        [gAppMgr.tabBarVC reloadTabBarVC];
        gAppMgr.huzhuTabUrl = op.huzhuTabUrl;
        gAppMgr.huzhuTabTitle = op.huzhuTabTitle;
    }];
}

- (RACSignal *)rac_getWeatherInfoWithReGeocode:(AMapLocationReGeocode *)regeo
{
    GetSystemTipsOp * op = [GetSystemTipsOp operation];
    op.province = regeo.province;
    op.city = regeo.city.length ? regeo.city : regeo.province;
    op.district = regeo.district;
    return [[[[op rac_postRequest] doNext:^(GetSystemTipsOp * op) {
        
        NSString * tip = [[op.rsp_temperature append:@"   "] append:op.rsp_temperaturetip];
        NSRange bigFontRange = NSMakeRange(0, op.rsp_temperature.length);
        [tip.customInfo safetySetObject:[NSValue valueWithRange:bigFontRange] forKey:KWeatherBigFontRange];
        gAppMgr.temperatureAndTip = tip;
        gAppMgr.temperaturepic = op.rsp_temperaturepic;
        gAppMgr.restriction = op.rsp_restriction;
    }] doError:^(NSError *error) {
        
        NSString * temperature = @"获取天气信息失败\n请重新下拉刷新";
        gAppMgr.temperatureAndTip = temperature;
        gAppMgr.temperaturepic = @"yin";
        gAppMgr.restriction = @"";
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal empty];
    }];
}



- (RACSignal *)rac_requestHomeSubmuduleWithUser:(JTUser *)user andReGeocode:(AMapLocationReGeocode *)code
{
    RACSignal * signal;
    if (user)
    {
        GetSystemHomeModuleOp * op = [[GetSystemHomeModuleOp alloc] init];
        op.province = code.province;
        op.city = code.city.length ? code.city : code.province;
        op.district = code.district;
        signal = [op rac_postRequest];
    }
    else
    {
        GetSystemHomeModuleNoLoginOp * op = [[GetSystemHomeModuleNoLoginOp alloc] init];
        op.province = code.province;
        op.city = code.city.length ? code.city : code.province;
        op.district = code.district;
        signal = [op rac_postRequest];
    }
    return signal;
}

- (void)handleLocationError:(NSError *)error
{
    NSString * text;
    text = @"请检查您是否打开了定位服务\n若已打开定位请重新下拉刷新";
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        NSRange range = NSMakeRange(9, 4);
        text.customInfo[KWeatherLinkRange] = [NSValue valueWithRange:range];
    }
    else
    {
        NSRange range = NSMakeRange(0, 0);
        text.customInfo[KWeatherLinkRange] = [NSValue valueWithRange:range];
    }

    gAppMgr.temperatureAndTip = text;
    gAppMgr.temperaturepic = @"yin";
    gAppMgr.restriction = @"";
}

// 为了保证该接口只调用一次，在获取用户操作之后3s运行，这个时候如果没有获取到地理位置就不管了
- (void)setupJSPatch
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [gSupportFileMgr setupJSPatch];
    });
}

#pragma mark - Lazy
- (HomePageModuleModel *)moduleModel
{
    if (!_moduleModel)
    {
        _moduleModel = [[HomePageModuleModel alloc] init];
    }
    return _moduleModel;
}

@end
