//
//  RCTNavigationManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTNavigationManager.h"
#import "NavigationModel.h"
#import "ReactNativeViewController.h"

@implementation RCTNavigationManager

RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(popViewAnimated:(BOOL)animated) {
    CKAsyncMainQueue(^{
        [gAppMgr.navModel.curNavCtrl popViewControllerAnimated:animated];
    });
}

RCT_EXPORT_METHOD(pushComponent:(NSString *)component withProperties:(NSDictionary *)properties andAnimated:(BOOL)animated) {
    ReactNativeViewController *vc = [[ReactNativeViewController alloc] initWithModuleName:component properties:properties];
    CKAsyncMainQueue(^{
        [gAppMgr.navModel.curNavCtrl pushViewController:vc animated:YES];
    });
}

@end
