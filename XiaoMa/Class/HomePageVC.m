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
#import "UIView+HKLine.h"
#import "NSString+RectSize.h"
#import "GetSystemTipsOp.h"
#import "GetSystemHomePicOp.h"

#import "HKLoginModel.h"
#import "MyCarStore.h"
#import "GuideStore.h"
#import "PasteboardModel.h"

#import "ADViewController.h"
#import "HomeNewbieGuideVC.h"
#import "HomeSuspendedAdVC.h"
#import "InviteAlertVC.h"
#import "AdListData.h"
#import "HKPopoverView.h"

#import "MyCouponVC.h"
#import "CouponPkgViewController.h"
#import "GetSystemHomeModuleOp.h"
#import "GetSystemHomeModuleNoLoginOp.h"
#import "AdListData.h"

#define WeatherRefreshTimeInterval 60 * 30
#define ItemCount 3

@interface HomePageVC ()<UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *weatherView;
@property (nonatomic, weak) HKPopoverView *popoverMenu;

@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, strong) ADViewController *secondAdCtrl;

@property (nonatomic, strong)UIView *mainItemView;
@property (nonatomic, strong)UIView *secondaryItemView;
@property (nonatomic, strong)UIView *containerView;
@property (nonatomic, strong)NSMutableArray * linesArray;

@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) GuideStore *guideStore;

/// 当前页面是否是homePageVC
@property (nonatomic, assign) BOOL isViewAppearing;
/// 是否展示广告
@property (nonatomic, assign) BOOL isShowSuspendedAd;
// 九宫格按钮的dispoable数据，控制点击事件释放
@property (nonatomic, strong)NSMutableArray * disposableArray;

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
    
    /// 移除右上角菜单栏
    [self.popoverMenu dismissWithAnimated:YES];
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
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 480);
        }
        [self showNewbieGuideAlertIfNeeded];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // iOS 7 下重新获取 contentSize
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        CGSize size = [self.containerView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, ceil(size.height))];
    }
}


#pragma mark - Setup
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
//    [self setupSecondViewInContainer:container withSquaresView:squaresView];
}

- (void)setupWeatherViewInContainer:(UIView *)containerView
{
    CGFloat dHeight = gAppMgr.deviceInfo.screenSize.height < 568.0 ? 568.0 : gAppMgr.deviceInfo.screenSize.height;
    
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
        
        CGFloat height = 92 / 1334.0f * dHeight;
        make.height.mas_equalTo(@(height));
    }];
}

- (UIView *)setupSquaresViewInContainer:(UIView *)container
{
    CGFloat deviceWidth = gAppMgr.deviceInfo.screenSize.width;
    ///，长宽比 250 ：210
    CGFloat squaresHeight = 208.0f / 250.0f * deviceWidth;
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
    [self setupSquaresView:squaresHeight];
    
    //小方块高度
    CGFloat squareHeight = squaresHeight / 3.0f;
    CGFloat squareWidth = deviceWidth / 3.0f;
    
    //9宫格加边框
    [squaresView drawLineWithDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsZero];
    [squaresView drawLineWithDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
    //9宫格里面的四条线 ＃
    [squaresView drawLineWithDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsMake(squareHeight, 0, 0, 0)];
    [squaresView drawLineWithDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsMake(squareHeight * 2, 0, 0, 0)];
    [squaresView drawLineWithDirection:CKViewBorderDirectionLeft withEdge:UIEdgeInsetsMake(0, squareWidth, 0, 0)];
    [squaresView drawLineWithDirection:CKViewBorderDirectionLeft withEdge:UIEdgeInsetsMake(0, squareWidth * 2, 0, 0)];
    
    return squaresView;
}


//- (void)setupSecondViewInContainer:(UIView *)container withSquaresView:(UIView *)squaresView
//{
//    UIView * secondaryView = [[UIView alloc] init];
//    secondaryView.tag = 102;
//    secondaryView.backgroundColor = [UIColor whiteColor];
//    [container addSubview:secondaryView];
//    
//    CGFloat height = 152.0f / 750.0f * gAppMgr.deviceInfo.screenSize.width;
//    [secondaryView mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        CGFloat space = 12;
//        make.top.equalTo(squaresView.mas_bottom).offset(space);
//        make.left.equalTo(self.scrollView);
//        make.right.equalTo(self.scrollView);
//        make.height.mas_equalTo(@(height)).priorityHigh();
//    }];
//    
//    HomeItem * bottomItem = gAppMgr.homePicModel.bottomItem;
//    UIButton * btn = [self functionalButtonWithImageName:bottomItem.defaultImageName action:nil inContainer:secondaryView andPicUrl:bottomItem.homeItemPicUrl];
//    btn.tag = 20201;
//    [secondaryView addSubview:btn];
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//       
//        make.left.right.top.bottom.equalTo(secondaryView);
//    }];
//    RACDisposable * disposable = [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        
//        [self jumpToViewControllerByUrl:bottomItem.homeItemRedirect];
//    }];
//    [self.disposableArray safetyAddObject:disposable];
//    
//    [squaresView drawLineWithDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
//    [squaresView drawLineWithDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsZero];
//    
//    [container mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(secondaryView);
//    }];
//}

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

- (void)setupSecondADViewInContainer:(UIView *)container  withSquaresView:(UIView *)squaresView
{
    //@fq TODO
    self.secondAdCtrl = [ADViewController vcWithADType:AdvertisementHomePage boundsWidth:self.view.frame.size.width
                                        targetVC:self mobBaseEvent:@""];
    
    CGFloat height = floor(self.secondAdCtrl.adView.frame.size.height);
    [container addSubview:self.secondAdCtrl.adView];
    [self.secondAdCtrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        CGFloat space = 12;
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

- (void)setupSquaresView:(CGFloat)height
{
    CGFloat squaresHeight = height;
    CGFloat squqresWidth = gAppMgr.deviceInfo.screenSize.width;
    UIView *squaresView = (UIView *)[self.view searchViewWithTag:101];
    for (NSInteger i = 0; i < gAppMgr.homePicModel.homeItemArray.count; i++)
    {
        HomeItem *item = [gAppMgr.homePicModel.homeItemArray safetyObjectAtIndex:i];
        
        [self mainButtonWithImageName:item.defaultImageName index:i jumpUrl:item.homeItemRedirect inContainer:squaresView andPicUrl:item.homeItemPicUrl width:squqresWidth/3.0 height:squaresHeight/3.0 isNewFlag:item.isNewFlag];
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
    if (!self.guideStore.shouldDisablePopupAd && self.isViewAppearing && !self.isShowSuspendedAd && ![[UIPasteboard generalPasteboard].string hasPrefix:XMINSPrefix]) {
        
        self.isShowSuspendedAd = YES;
        
        @weakify(self);
        RACSignal *signal = [gAdMgr rac_getAdvertisement:AdvertisementAlert];
        [[signal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *ads) {
            
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
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
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
    } error:^(NSError *error) {
        gAppDelegate.pushMgr.notifyQueue.running = YES;
        gAppDelegate.openUrlQueue.running = YES;
        //未登录
        [self checkPasteboardModel];
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
    @weakify(self);
    RACSignal *sig1 = [[[[[gMapHelper rac_getInvertGeoInfo] take:1] initially:^{
        @strongify(self);
        [self setupNavigationLeftBar:@"定位中..."];
    }] doError:^(NSError *error) {
        @strongify(self);
        [self setupNavigationLeftBar:nil];
        [gMapHelper handleGPSError:error];
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

    RACSignal * userSignal = [RACObserve(gAppMgr, myUser) distinctUntilChanged];
    
    RACSignal * combineSignal = [RACSignal combineLatest:@[sig1,userSignal] reduce:^(AMapReGeocode *regeo, JTUser * user) {
        return RACTuplePack(regeo,user);
    }];
    
    RACSignal * homeSubmudleSignal = [combineSignal flattenMap:^RACStream *(RACTuple *tuple) {
        
        AMapReGeocode *regeo = tuple.first;
        JTUser * user = tuple.second;
        return [self rac_requestHomeSubmuduleWithUser:user andReGeocode:regeo];
    }];
    
    [homeSubmudleSignal subscribeNext:^(GetSystemHomeModuleOp * op) {
        
        gAppMgr.homePicModel = [gAppMgr.homePicModel analyzeHomePicModel:op.homeModel];
        [gAppMgr saveHomePicInfo];
        [self refreshSquareView];
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





- (UIButton *)functionalButtonWithImageName:(NSString *)imgName action:(SEL)action inContainer:(UIView *)container andPicUrl:(NSString *)picUrl
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
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

- (UIButton *)mainButtonWithImageName:(NSString *)imgName index:(NSInteger)index jumpUrl:(NSString *)url inContainer:(UIView *)container andPicUrl:(NSString *)picUrl width:(CGFloat)width height:(CGFloat)height isNewFlag:(BOOL)flag
{
    NSInteger tag = 20101;
    UIButton * btn = [self functionalButtonWithImageName:imgName action:nil inContainer:container andPicUrl:picUrl];
    RACDisposable * disposable = [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self jumpToViewControllerByUrl:url];
    }];
    [self.disposableArray safetyAddObject:disposable];
    btn.tag = tag + index;
    
    NSInteger quotient = index / ItemCount;
    NSInteger remiainder = index % ItemCount;
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        make.top.equalTo(container).offset(height * quotient);
        make.left.equalTo(container).offset(width * remiainder);
    }];
    
    NSInteger iconTag = 2010101 + index;
    UIImageView * iconNewImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hp_new_icon"]];
    iconNewImageV.tag = iconTag;
    [btn addSubview:iconNewImageV];
    
    [iconNewImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.top.equalTo(btn);
        make.right.equalTo(btn);
    }];
    
    iconNewImageV.hidden = !flag;
    
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

//刷新九宫格
- (void)refreshSquareView
{
    UIView *firstView = (UIView *)[self.view searchViewWithTag:101];
    
    for (RACDisposable * disposable in self.disposableArray)
    {
        [disposable dispose];
    }
    [self.disposableArray removeAllObjects];
    
    for (NSInteger i = 0; i < gAppMgr.homePicModel.homeItemArray.count; i++)
    {
        HomeItem *item = [gAppMgr.homePicModel.homeItemArray safetyObjectAtIndex:i];
        NSInteger btnTag = 20101 + i;
        UIButton * btn = (UIButton *)[firstView searchViewWithTag:btnTag];
        
        NSInteger iconNewTag = 2010101 + i;
        UIImageView * imageView = (UIImageView *)[btn searchViewWithTag:iconNewTag];
        imageView.hidden = item.isNewFlag;
        
        [self requestHomePicWithBtn:btn andUrl:item.homeItemPicUrl andDefaultPic:nil errPic:nil];
        
        RACDisposable * disposable = [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [self jumpToViewControllerByUrl:item.homeItemRedirect];
            // 把new标签设置回去
            if (item.isNewFlag)
            {
                item.isNewFlag = NO;
            }
            [gAppMgr saveHomePicInfo];
        }];
        [self.disposableArray safetyAddObject:disposable];
    }
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


- (void)jumpToViewControllerByUrl:(NSString *)url
{
    [gAppMgr.navModel pushToViewControllerByUrl:url];
}

- (RACSignal *)rac_requestHomeSubmuduleWithUser:(JTUser *)user andReGeocode:(AMapReGeocode *)code
{
    RACSignal * signal;
    if (user)
    {
        GetSystemHomeModuleOp * op = [[GetSystemHomeModuleOp alloc] init];
        op.province = code.addressComponent.province;
        op.city = code.addressComponent.city;
        op.district = code.addressComponent.district;
        signal = [op rac_postRequest];
    }
    else
    {
        GetSystemHomeModuleNoLoginOp * op = [[GetSystemHomeModuleNoLoginOp alloc] init];
        op.province = code.addressComponent.province;
        op.city = code.addressComponent.city;
        op.district = code.addressComponent.district;
        signal = [op rac_postRequest];
    }
    return signal;
}

#pragma mark - MenuItems
- (CKDict *)menuItemCoupon {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Invite",@"title":@"优惠券",@"img":@"hp_coupon_300"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
        vc.jumpType = CouponNewTypeCarWash;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (CKDict *)menuItemCouponPkg {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Invite",@"title":@"兑换礼包",@"img":@"hp_pkg_300"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        CouponPkgViewController *vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"CouponPkgViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (CKDict *)menuItemCallService {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Invite",@"title":@"咨询客服",@"img":@"hp_service_300"}];
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"rp101_2"];
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
    });
    return dict;
}


@end
