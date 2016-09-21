//
//  ViewControllerFactory.m
//  XMDD
//
//  Created by jiangjunchen on 16/7/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewControllerFactory.h"
#import "ReactNativeManager.h"
#import "ReactNativeViewController.h"
#import "MutualInsVC.h"

@implementation HKViewControllerFactory

+ (__kindof UIViewController *)mutualInsVCWithChannel:(NSString *)channel {
    if ([[ReactNativeManager sharedManager] checkReactNativeEnabledIfNeeded]) {
        NSDictionary *props = @{@"title": @"小马互助", @"shouldBack": @YES,@"sensorChannel":channel ?: @""};
        UIViewController *vc = [[ReactNativeViewController alloc] initWithModuleName:@"MutualInsView" properties:props];
        vc.router.key = @"MutualInsVC";
        return vc;
    }
    
    MutualInsVC * vc = [UIStoryboard vcWithId:@"MutualInsVC" inStoryboard:@"MutualInsJoin"];
    vc.sensorChannel = channel;
    return vc;
}

@end
