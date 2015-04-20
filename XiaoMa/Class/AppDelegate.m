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
<<<<<<< HEAD
#import <AFNetworking.h>
#import <CocoaLumberjack.h>
#import "AuthByVcodeOp.h"
#import "GetTokenOp.h"
#import "GetVcodeOp.h"
#import "HKCatchErrorModel.h"
#import "GetShopByRangeOp.h"

@interface AppDelegate ()
@property (nonatomic, strong) DDFileLogger *fileLogger;
=======
#import "MapHelper.h"
#import "GetTokenOp.h"
#import "GetVcodeOp.h"
#import "AlipayHelper.h"

@interface AppDelegate ()


>>>>>>> 1d764f58f03a8f1935e7764c56bf5fb6816b0a56
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
    
<<<<<<< HEAD
//    GetTokenOp * op = [GetTokenOp operation];
//    op.phone = @"13958064824";
//    [[op rac_postRequest] subscribeNext:^(GetTokenOp * op) {
//        
//        gNetworkMgr.token = op.token;
//        
//        GetVcodeOp * op2 = [GetVcodeOp operation];
//        op2.phone = @"13958064824";
//        op2.token = gNetworkMgr.token;
//        op2.type = @"3";
//        
//        [[op2 rac_postRequest] subscribeNext:^(GetVcodeOp * op2) {
//            
//        }];
//    }];
=======
    [gMapHelper setupMapApi];
    [gMapHelper setupMAMap];
    
    GetTokenOp * op = [GetTokenOp operation];
    op.phone = @"13958064824";
    [[op rac_postRequest] subscribeNext:^(GetTokenOp * op) {
        
        gNetworkMgr.token = op.token;
        
        GetVcodeOp * op2 = [GetVcodeOp operation];
        op2.phone = @"13958064824";
        op2.token = gNetworkMgr.token;
        op2.type = @"3";
        
        [[op2 rac_postRequest] subscribeNext:^(GetVcodeOp * op2) {
            
        }];
    }];
>>>>>>> 1d764f58f03a8f1935e7764c56bf5fb6816b0a56
    
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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

@end
