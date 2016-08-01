//
//  AppDelegate.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
// test 

#import "AppDelegate.h"
#import "Xmdd.h"
#import <AFNetworking.h>
#import <CocoaLumberjack.h>
#import <TencentOpenAPI.framework/Headers/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import <JPEngine.h>
#import "RRFPSBar.h"
#import "ReactNativeManager.h"

#import "DefaultStyleModel.h"

#import "HKLoginModel.h"
#import "MapHelper.h"

#import "HKLaunchManager.h"
#import "ShareResponeManager.h"
#import "PasteboardModel.h"

#import "GetSystemTipsOp.h"
#import "GetSystemVersionOp.h"
#import "GetsSystemSwitchConfigOp.h"
#import "GetSystemJSPatchOp.h"

#import "ClientInfo.h"
#import "DeviceInfo.h"
#import "HKAdvertisement.h"
#import "FMDeviceManager.h"

#import "MainTabBarVC.h"
#import "LaunchVC.h"
#import "WelcomeVC.h"



#define RequestWeatherInfoInterval 60 * 10
//#define RequestWeatherInfoInterval 5

@interface AppDelegate ()<WXApiDelegate,TencentSessionDelegate,CrashlyticsDelegate>

@property (nonatomic, strong) DDFileLogger *fileLogger;

@property (nonatomic, strong) HKLaunchManager *launchMgr;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //设置日志系统
    [self setupLogger];
    //设置错误处理
    [self setupErrorModel];
    //设置默认UI样式
    [DefaultStyleModel setupDefaultStyle];
    
    ///设置地图
    [gMapHelper setupMapApi];
    //设置友盟
    [self setupUmeng];
    //设置url缓存
    [self setupURLCache];
    //设置推送
    [self setupPushManagerWithOptions:launchOptions];
    // 第三方授权
    [self setupThirdPartyAuthorization];
    //检测版本更新
    [self setupVersionUpdating];
    [self setupSwitchConfiguation];
    //设置启动页管理器
    [self setupLaunchManager];
    [self setupRootView];
    //设置同盾
    [self setFMDeviceManager];
    
    [self setupJSPatch];
    
    [self setupOpenUrlQueue];
    
    [self setupPasteboard];
    
    [self setupAssistive];
    
    [self setupReactNative];
    //设置崩溃捕捉(官方建议放在最后面)
    [self setupCrashlytics];
    
    return YES;
}


#pragma mark - Initialize
- (void)setupLaunchManager
{
    self.launchMgr = [[HKLaunchManager alloc] init];
}

- (void)setupRootView
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc;
    
    //如果本地没有启动页的相关信息，则直接进入主页，否则进入启动页
    HKLaunchInfo *info = [self.launchMgr fetchLatestLaunchInfo];
    NSString *url = [info croppedPicUrl];
    if (!info || ![gMediaMgr cachedImageExistsForUrl:url]) {
        vc = [UIStoryboard vcWithId:@"MainTabBarVC" inStoryboard:@"Main"];
    }
    else {
        LaunchVC *lvc = [UIStoryboard vcWithId:@"LaunchVC" inStoryboard:@"Launch"];
        [lvc setImage:[gMediaMgr imageFromDiskCacheForUrl:url]];
        [lvc setInfo:info];
        vc = lvc;
    }
    [self resetRootViewController:vc];
}

- (void)resetRootViewController:(UIViewController *)vc
{
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)setupLogger
{
    DebugFormat *formatter = [[DebugFormat alloc] init];
    
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // xcode 控制台日志
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    // 日志输入颜色控制
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor whiteColor] backgroundColor:[UIColor blackColor] forFlag:DDLogFlagVerbose];

    [[DDTTYLogger sharedInstance] setForegroundColor:kDefTintColor backgroundColor:[UIColor blackColor] forFlag:DDLogFlagDebug];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:kOrangeColor backgroundColor:[UIColor blackColor] forFlag:DDLogFlagInfo];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:[UIColor whiteColor] forFlag:DDLogFlagWarning];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:[UIColor whiteColor] forFlag:DDLogFlagError];
    
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 100;
    self.fileLogger.maximumFileSize = 5 * 1024 * 1024;
    //fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    [self.fileLogger setLogFormatter:formatter];
    [DDLog addLogger:self.fileLogger];
    
    /// 苹果系统日志
    [DDLog addLogger:[DDASLLogger sharedInstance]];
}

- (void)setupErrorModel
{
    self.errorModel = [[HKCatchErrorModel alloc] init];
    [self.errorModel catchNetworkingError];
}

- (void)setupURLCache
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:200*1024*1024 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

- (void)setupPushManagerWithOptions:(NSDictionary *)launchOptions
{
    self.pushMgr = [[HKPushManager alloc] init];
    [self.pushMgr setupWithOptions:launchOptions];
    [self.pushMgr autoBindDeviceTokenInBackground];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    

    CKAsyncDefaultQueue(^{
        NSDate * lastLocationTime = [NSDate dateWithText:[gAppMgr getInfo:LastLocationTime]];
        NSTimeInterval timeInterval = [lastLocationTime timeIntervalSinceNow];
        if (fabs(timeInterval) > RequestWeatherInfoInterval)
        {
            CKAsyncMainQueue(^{
                [self getLocation];
            });
        }
    });
    
    if (![self checkVersionUpdating])
    {
        // 不需要更新的情况下去查询小马互助
        [self.pasteboardoModel checkPasteboard];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //每次应用激活，都尝试更新一下启动页的信息
    [self.launchMgr checkLaunchInfoUpdating];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.absoluteString hasPrefix:WECHAT_APP_ID]) {
        return [WXApi handleOpenURL:url delegate:[ShareResponeManager init]];
    }
    else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"wb%@", WEIBO_APP_ID]]) {
        return [WeiboSDK handleOpenURL:url delegate:[ShareResponeManager init]];
    }
    else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"tencent%@", QQ_API_ID]]) {
        return [QQApiInterface handleOpenURL:url delegate:[ShareResponeManager init]];
    }
    else if ([url.absoluteString hasPrefix:@"xmdd://"])
    {
        [MobClick event:@"rp000"];
        NSString * urlStr = url.absoluteString;
        NSDictionary * dict = @{@"url":urlStr};
        [self.openUrlQueue addObject:dict forKey:nil];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.pushMgr registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DebugLog(@"didReceiveRemoteNotification :%@",userInfo);
    [MobClick event:@"rp000"];
    [self.pushMgr handleNofitication:userInfo forApplication:application];
}

#pragma mark - QQ
- (void)tencentDidLogin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessed" object:self];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:self];
}

- (void)tencentDidNotNetWork
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:self];
}

#pragma mark - 友盟
- (void)setupUmeng
{
    UMConfigInstance.appKey = UMeng_API_ID;
    UMConfigInstance.channelId = @"App Store";
    UMConfigInstance.bCrashReportEnabled = NO;
    UMConfigInstance.ePolicy = BATCH;
    
    [MobClick startWithConfigure:UMConfigInstance];
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#else
    [MobClick setLogEnabled:NO];
#endif
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
}


#pragma mark - Crashlytics
- (void)setupCrashlytics
{
    /// 设置delegate必须在前面，（先关闭）
//    CrashlyticsKit.delegate = self;
    
#ifdef DEBUG
    
#else
    #if XMDDEnvironment==2
    [Fabric with:@[CrashlyticsKit]];
    
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(JTUser *user) {
        
        NSString * userIdentifier = user ? user.userID : @"";
        [CrashlyticsKit setUserIdentifier:userIdentifier];
    }];
    #endif
#endif
    
}

- (void)crashlyticsDidDetectReportForLastExecution:(CLSReport *)report completionHandler:(void (^)(BOOL))completionHandler
{
    // 可以在这里做一些操作，操作完必须调用completionHandler，否则无法将report提交到fabric,
    
    CKAsyncMainQueue(^{
        
        completionHandler(YES);
    });
}

#pragma mark - Utilities
- (void)getLocation
{
    [[[gMapHelper rac_getUserLocationAndInvertGeoInfoWithAccuracy:kCLLocationAccuracyKilometer] initially:^{
        
    }] subscribeNext:^(id x) {
        
        [self requestWeather:gMapHelper.addrComponent.province andCity:gMapHelper.addrComponent.city andDistrict:gMapHelper.addrComponent.district];
        
        /// 存储一下上次定位时间
        NSString * dateStr = [[NSDate date] dateFormatForDT15];
        [gAppMgr saveInfo:dateStr forKey:LastLocationTime];
        
    } error:^(NSError *error) {
        
        [gMapHelper handleGPSError:error];
    }];
}

- (void)requestWeather:(NSString *)p andCity:(NSString *)c andDistrict:(NSString *)d
{
    GetSystemTipsOp * op = [GetSystemTipsOp operation];
    op.province = p;
    op.city = c;
    op.district = d;
    [[op rac_postRequest] subscribeNext:^(GetSystemTipsOp * op) {
        
        gAppMgr.temperatureAndTip = [op.rsp_temperature append:op.rsp_temperaturetip];
        gAppMgr.temperaturepic = op.rsp_temperaturepic;
        gAppMgr.restriction = op.rsp_restriction;
    }];
}

- (void)setupVersionUpdating
{
    //移除2.0版本前缓存的token和密码,2.0版本前有密码登录
    if ([gAppMgr.deviceInfo firstAppearAfterVersion:@"2.0" forKey:@"loginInfo"]) {
        [HKLoginModel logout];
    }

    NSString * version = gAppMgr.clientInfo.clientVersion;
    NSString * OSVersion = gAppMgr.deviceInfo.osVersion;
    GetSystemVersionOp * op = [GetSystemVersionOp operation];
    op.appid = IOSAPPID;
    op.version = version;
    op.os = [NSString stringWithFormat:@"iOS %@",OSVersion];
    [[op rac_postRequest] subscribeNext:^(GetSystemVersionOp * op) {
        
        [gToast dismiss];
        if([version compare:op.rsp_version options:NSCaseInsensitiveSearch | NSNumericSearch] == NSOrderedAscending)
        {
            if (op.rsp_mandatory)
            {
                gAppMgr.clientInfo.forceUpdateUrl = op.rsp_link;
                gAppMgr.clientInfo.forceUpdateContent = op.rsp_updateinfo;
                gAppMgr.clientInfo.forceUpdateVersion = op.rsp_version;
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有新的版本可以更新：%@",op.rsp_version] message:op.rsp_updateinfo delegate:self cancelButtonTitle:@"前去更新" otherButtonTitles:nil];
                [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNumber) {
                    [gAppMgr startUpdatingWithURLString:op.rsp_link];
                }];
                [av show];
            }
            else
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有新的版本可以更新：%@",op.rsp_version] message:op.rsp_updateinfo  delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"前去更新",nil];
                [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNumber) {
                    if ([indexNumber intValue] == 1) {
                        [gAppMgr startUpdatingWithURLString:op.rsp_link];
                    }
                }];
                [av show];
            }
        }
    }];
}


/// 检查更新
- (BOOL)checkVersionUpdating
{
    if (gAppMgr.clientInfo.forceUpdateUrl.length)
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有新的版本可以更新：%@",gAppMgr.clientInfo.forceUpdateVersion]
                                                      message:gAppMgr.clientInfo.forceUpdateContent
                                                     delegate:self
                                            cancelButtonTitle:@"前去更新"
                                            otherButtonTitles:nil];
        [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNumber) {
            [gAppMgr startUpdatingWithURLString:gAppMgr.clientInfo.forceUpdateUrl];
        }];
        [av show];
        
        return YES;
    }
    return NO;
}

/// 分享开关
- (void)setupSwitchConfiguation
{
    NSString * version = gAppMgr.clientInfo.clientVersion;
    NSString * OSVersion = gAppMgr.deviceInfo.osVersion;
    GetsSystemSwitchConfigOp * op = [GetsSystemSwitchConfigOp operation];
    op.appid = IOSAPPID;
    op.version = version;
    op.os = [NSString stringWithFormat:@"iOS %@",OSVersion];
    [[op rac_postRequest] subscribeNext:^(GetsSystemSwitchConfigOp * op) {
        NSDictionary * dict = op.rsp_configurations;
        gAppMgr.canShareFlag = [dict boolParamForName:@"isshare"];
    } error:^(NSError *error) {
        
        DebugLog(@"GetsSystemSwitchConfigOp失败，%@",error.domain);
    }];
}

- (void)setupThirdPartyAuthorization
{
    //微信授权
    if (![WXApi registerApp:WECHAT_APP_ID])
    {
        DebugLog(@"Wechat register Failed");
    }
    //微博授权
    if (![WeiboSDK registerApp:WEIBO_APP_ID])
    {
        DebugLog(@"Weibo register Failed");
    }
    //QQ接口调用授权
    if (![[TencentOAuth alloc] initWithAppId:QQ_API_ID
                                 andDelegate:self])
    {
        DebugLog(@"QQ register Failed");
    }
}

- (void)setupOpenUrlQueue
{
    self.openUrlQueue = [[JTQueue alloc] init];
    
    [self.openUrlQueue setConsumeBlock:^RACSignal *(NSDictionary *info, id<NSCopying>key) {
        
        DDLogDebug(@"OpenUrlQueue,%@",info[@"url"]);
        [gAppMgr.navModel pushToViewControllerByUrl:info[@"url"]];
        return [RACSignal empty];
    }];
}

#pragma mark - ReactNative
- (void)setupReactNative {
    [[ReactNativeManager sharedManager] loadDefaultBundle];
}

#pragma mark - 同盾
- (void)setFMDeviceManager {
    // 获取设备管理器实例
    FMDeviceManager_t *manager = [FMDeviceManager sharedManager];
    
    // 准备SDK初始化参数
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    // SDK具有防调试功能，当使用xcode运行时，请取消此行注释，开启调试模式
    // 否则使用xcode运行会闪退，(但直接在设备上点APP图标可以正常运行)
    // 上线Appstore的版本，请记得删除此行，否则将失去防调试防护功能！
     [options setValue:@"allowd" forKey:@"allowd"];
    
    // 指定对接同盾的测试环境，正式上线时，请删除或者注释掉此行代码，切换到同盾生产环境
#ifdef DEBUG
    [options setValue:@"sandbox" forKey:@"env"];
#endif
    // 指定合作方标识
    [options setValue:@"xiaomadada" forKey:@"partner"];
    
    // 使用上述参数进行SDK初始化
    manager->initWithOptions(options);
}


#pragma mark - JSPatch
- (void)setupJSPatch
{
    return;
    RACSignal * userSignal = [RACObserve(gAppMgr, myUser) distinctUntilChanged];
    RACSignal * areaSignal = [[RACObserve(gMapHelper, addrComponent) distinctUntilChanged] filter:^BOOL(HKAddressComponent * ac) {
        return ac.province.length || ac.city.length || ac.district.length;
    }];
    
    RACSignal * combinedSignal = [[userSignal combineLatestWith:areaSignal] take:1];
    [combinedSignal subscribeNext:^(RACTuple * tuple) {
        
        JTUser * u = tuple.first;
        HKAddressComponent * ac = tuple.second;
        NSString * version = gAppMgr.clientInfo.clientVersion;
        
        GetSystemJSPatchOp * op = [GetSystemJSPatchOp operation];
        op.phoneNumber = u.userID;
        op.version = version;
        op.province = ac.province;
        op.city = ac.city;
        op.district = ac.district;
        
        [[[op rac_postRequest] flattenMap:^RACStream *(GetSystemJSPatchOp * rop) {
            
            NSString * url = rop.rsp_jspatchUrl;
            return [gSupportFileMgr rac_handleSupportFile:url];
        }] subscribeNext:^(RACTuple * tuple) {
            
            
            NSString * filePath = tuple.first;
            [JPEngine startEngine];
            NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            [JPEngine evaluateScript:script];
        }];
    }];
}

///剪切板设置
- (void)setupPasteboard
{
    _pasteboardoModel = [[PasteboardModel alloc] init];
}


#pragma mark - FPS
- (void)setupFPSObserver
{
#ifndef __OPTIMIZE__
    [[RRFPSBar sharedInstance] setShowsAverage:YES];
    [[RRFPSBar sharedInstance] setHidden:YES];
#endif
}


#pragma mark - 辅助功能
- (void)setupAssistive
{
    [gAssistiveMgr setupFPSObserver];
}

#pragma mark - UIResponser
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
#ifdef DEBUG
    gAssistiveMgr.isShowAssistiveView = !gAssistiveMgr.isShowAssistiveView;
#endif
}
@end
