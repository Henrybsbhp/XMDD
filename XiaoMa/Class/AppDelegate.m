//
//  AppDelegate.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AppDelegate.h"
#import "XiaoMa.h"
#import "DefaultStyleModel.h"
#import <AFNetworking.h>
#import <CocoaLumberjack.h>
#import "HKCatchErrorModel.h"
#import "MapHelper.h"
#import "GetSystemTipsOp.h"
#import "GetSystemVersionOp.h"
#import "GetsSystemSwitchConfigOp.h"
#import "ClientInfo.h"
#import "DeviceInfo.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI.framework/Headers/TencentOAuth.h>
#import "JTLogModel.h"
#import <UMengAnalytics/MobClick.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "WelcomeViewController.h"
#import "MainTabBarVC.h"
#import "HKAdvertisement.h"
#import "LaunchVC.h"
#import "HKLaunchManager.h"

#define RequestWeatherInfoInterval 60 * 10
//#define RequestWeatherInfoInterval 5

@interface AppDelegate ()<WXApiDelegate,TencentSessionDelegate>

@property (nonatomic, strong) DDFileLogger *fileLogger;

/// 日志
@property (nonatomic,strong)JTLogModel * logModel;
@property (nonatomic, strong) HKCatchErrorModel *errorModel;
@property (nonatomic, strong) HKLaunchManager *launchMgr;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //设置日志系统
    [self setupLogger];
    //设置错误处理
    [self setupErrorModel];
    //设置默认UI样式
    [DefaultStyleModel setupDefaultStyle];
    
    [gMapHelper setupMapApi];
    [gMapHelper setupMAMap];
    //设置友盟
    [self setupUmeng];
    //设置崩溃捕捉
    [self setupCrashlytics];
    //设置url缓存
    [self setupURLCache];
    //设置推送
    [self setupPushManagerWithOptions:launchOptions];
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
    //检测版本更新
    [self setupVersionUpdating];
    [self setupSwitchConfiguation];
    //设置启动页管理器
    [self setupLaunchManager];
    [self setupRootView];
    
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
    if ([gAppMgr.deviceInfo firstAppearAtThisVersionForKey:@"$GuideView"]) {
        vc = [UIStoryboard vcWithId:@"WelcomeViewController" inStoryboard:@"Main"];
    }
    else {
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
    
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 100;
    self.fileLogger.maximumFileSize = 5 * 1024 * 1024;
    //fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    [self.fileLogger setLogFormatter:formatter];
    [DDLog addLogger:self.fileLogger];
    
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

    [self checkVersionUpdating];
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
    NSLog(@"didReceiveRemoteNotification :%@",userInfo);
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
    [MobClick setCrashReportEnabled:NO];
    [MobClick startWithAppkey:UMeng_API_ID reportPolicy:BATCH   channelId:@"iOS"];
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#else
    [MobClick setLogEnabled:NO];
#endif
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    [MobClick startSession:nil];
    
    //[self getDeviceIDForMob];
}

///友盟实时监测，设备身份申请码获取
- (NSString *)getDeviceIDForMob
{
    Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
    NSString *deviceID = nil;
    if(cls && [cls respondsToSelector:deviceIDSelector]){
        deviceID = [cls performSelector:deviceIDSelector];
    }
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString * deviceIDStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", deviceIDStr);
    return deviceIDStr;
}

#pragma mark - Crashlytics
- (void)setupCrashlytics
{
    [Fabric with:@[CrashlyticsKit]];
}

#pragma mark - Utilities
- (void)requestStaticPromotion
{}

- (void)requestAd
{}

- (void)requestUpdateInfo
{}

- (void)getLocation
{
    [[[gMapHelper rac_getInvertGeoInfo] initially:^{
        
    }] subscribeNext:^(AMapReGeocode * getInfo) {
        
        if (!([getInfo.addressComponent.province isEqualToString:gAppMgr.province] &&
            [getInfo.addressComponent.city isEqualToString:gAppMgr.city] &&
            [getInfo.addressComponent.district isEqualToString:gAppMgr.district]))
        {
            [self requestWeather:getInfo.addressComponent.province andCity:getInfo.addressComponent.city andDistrict:getInfo.addressComponent.district];
        }
        
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
    [[op rac_postRequest] subscribeNext:^(GetSystemTipsOp * op) {
        
        if(op.rsp_code == 0)
        {
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
    }];
}

- (void)setupVersionUpdating
{
    //TODO:移除2.0版本前缓存的token和密码
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


- (void)checkVersionUpdating
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
    }
}

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


#pragma mark - 日志
#pragma mark - UIResponser
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
#ifdef DEBUG
    if (motion != UIEventSubtypeMotionShake)
        return;
    if (!self.logModel)
    {
        self.logModel = [[JTLogModel alloc] init];
    }
    else
    {
        if (self.logModel.islogViewAppear)
        {
            return;
        }
    }
    self.logModel.userid = gAppMgr.myUser.userID ? gAppMgr.myUser.userID : @"00000000000";
    self.logModel.appname = @"com.huika.xmdd";
    [self.logModel addToScreen];
#endif
}


@end
