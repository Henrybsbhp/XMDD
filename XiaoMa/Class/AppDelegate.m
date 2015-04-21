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
#import "AuthByVcodeOp.h"
#import "GetTokenOp.h"
#import "GetVcodeOp.h"
#import "HKCatchErrorModel.h"
#import "GetShopByRangeOp.h"
#import "MapHelper.h"
#import "GetTokenOp.h"
#import "GetVcodeOp.h"
#import "AlipayHelper.h"
#import "GetSystemTipsOp.h"

//#define RequestWeatherInfoInterval 60 * 10
#define RequestWeatherInfoInterval 5

@interface AppDelegate ()
@property (nonatomic, strong) DDFileLogger *fileLogger;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //设置日志系统
    [self setupLogger];
    //设置错误处理
    [HKCatchErrorModel catchNetworkingError];
    //设置默认UI样式
    [DefaultStyleModel setupDefaultStyle];
    
    [gMapHelper setupMapApi];
    [gMapHelper setupMAMap];
    
        
    return YES;
}

#pragma mark - Initialize
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    ///如果距上次定位时间超过10分钟，则首页呈现的时候，重新定位
    NSDate * lastLocationTime = [NSDate dateWithText:[gAppMgr getInfo:LastLocationTime]];
    NSTimeInterval timeInterval = [lastLocationTime timeIntervalSinceNow];
    if (abs(timeInterval) > RequestWeatherInfoInterval)
    {
        [self getLocation];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [self handleURL:url];
    return YES;
}


#pragma mark - 支付宝
- (void)handleURL:(NSURL *)url
{
    AlixPayResult* result = [self handleOpenURL:url];
    
    if (result && result.statusCode == 9000)
    {
        /*
         *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
         */
        
        //交易成功
        //            NSString* key = @"签约帐户后获取到的支付宝公钥";
        //			id<DataVerifier> verifier;
        //            verifier = CreateRSADataVerifier(key);
        //
        //			if ([verifier verifyString:result.resultString withSign:result.signString])
        //            {
        //                //验证签名成功，交易结果无篡改
        //			}
        //            RACSubject * sub = [RACSubject subject];
        
        
        [gAlipayHelper.rac_alipayResultSignal sendNext:@"9000"];
    }
    else
    {
        [gAlipayHelper.rac_alipayResultSignal sendError:[NSError errorWithDomain:result.statusMessage code:result.statusCode userInfo:nil]];
    }
}


- (AlixPayResult *)resultFromURL:(NSURL *)url {
    NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#if ! __has_feature(objc_arc)
    return [[[AlixPayResult alloc] initWithString:query] autorelease];
#else
    return [[AlixPayResult alloc] initWithString:query];
#endif
}

- (AlixPayResult *)handleOpenURL:(NSURL *)url {
    AlixPayResult * result = nil;
    
    if (url != nil && [[url host] compare:@"safepay"] == 0) {
        result = [self resultFromURL:url];
    }
    
    return result;
}

#pragma mark - Utilities
- (void)requestStaticPromotion
{}

- (void)requestAd
{}

- (void)requestUpdateInfo
{
    
}

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
            case 7001:
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




@end
