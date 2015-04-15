//
//  AppDelegate.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultStyleModel.h"
#import <AFNetworking.h>
#import "AuthByVcodeOp.h"
#import "GetTokenOp.h"
#import "GetVcodeOp.h"
#import "GetShopByRangeOp.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [DefaultStyleModel setupDefaultStyle];
    
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
    
    return YES;
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

@end
