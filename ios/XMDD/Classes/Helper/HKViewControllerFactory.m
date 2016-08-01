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

@implementation HKViewControllerFactory

+ (__kindof UIViewController *)mutualInsVC {
    if ([[ReactNativeManager sharedManager] isReactNativeEnabled]) {
        return [[ReactNativeViewController alloc] initWithModuleName:@"MutualInsView" properties:@{@"title": @"小马互助",
                                                                                                   @"shouldBack": @YES}];
    }
    return [UIStoryboard vcWithId:@"MutualInsVC" inStoryboard:@"MutualInsJoin"];
}

@end
