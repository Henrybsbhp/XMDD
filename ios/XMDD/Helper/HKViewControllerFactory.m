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
#import "MutualInsHomeAdVC.h"
#import "AboutViewController.h"

@implementation HKViewControllerFactory

+ (__kindof UIViewController *)aboutUsVC
{
    if ([[ReactNativeManager sharedManager] checkReactNativeEnabledIfNeeded]) {
        NSDictionary *props = @{@"title": @"关于RN-哈哈哈"};
        UIViewController *vc = [[ReactNativeViewController alloc] initWithHref:@"/Mine/AboutUs" properties:props];
        return vc;
    }
    
    AboutViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    return vc;
}

+ (__kindof UIViewController *)mutualInsVCWithChannel:(NSString *)channel {
    if ([[ReactNativeManager sharedManager] checkReactNativeEnabledIfNeeded]) {
        NSDictionary *props = @{@"title": @"小马互助", @"shouldBack": @YES,@"sensorChannel":channel ?: @""};
        UIViewController *vc = [[ReactNativeViewController alloc] initWithHref:@"/MutualIns/Home" properties:props];
        return vc;
    }
    
    MutualInsVC * vc = [UIStoryboard vcWithId:@"MutualInsVC" inStoryboard:@"MutualInsJoin"];
    vc.sensorChannel = channel;
    return vc;
}

///小马互助首页广告
+ (__kindof UIViewController *)mutualInsHomeAdVCWithChannel:(NSString *)channel {
    if ([[ReactNativeManager sharedManager] checkReactNativeEnabledIfNeeded]) {
        NSDictionary *props = @{@"title": @"小马互助", @"shouldBack": @YES,@"sensorChannel":channel ?: @""};
        UIViewController *vc = [[ReactNativeViewController alloc] initWithHref:@"/MutualIns/ADHome" properties:props];
        vc.router.key = @"/MutualIns/Home";
        return vc;
    }
    MutualInsHomeAdVC *vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsHomeAdVC"];
    vc.sensorChannel = channel;
    return vc;
}

+ (__kindof UIViewController *)mutualInsGroupIntroVCWithGroupType:(MutualGroupType)type {
    if ([[ReactNativeManager sharedManager] checkReactNativeEnabledIfNeeded]) {
        NSDictionary *props = @{@"title":@"小马互助", @"shouldBack": @YES, @"groupType": @(type)};
        UIViewController *vc = [[ReactNativeViewController alloc] initWithHref:@"/MutualIns/GroupIntro" properties:props];
        return vc;
    }
    GroupIntroductionVC *vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"GroupIntroductionVC"];
    vc.groupType = type;
    return vc;
}

@end
