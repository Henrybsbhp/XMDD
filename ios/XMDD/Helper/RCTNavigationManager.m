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

RCT_EXPORT_METHOD(pushViewControllerByUrl:(NSString *)url) {
    CKAsyncMainQueue(^{
        [gAppMgr.navModel pushToViewControllerByUrl:url];
    });
}

RCT_EXPORT_METHOD(pushComponent:(NSString *)component withProperties:(NSDictionary *)properties andAnimated:(BOOL)animated) {
    ReactNativeViewController *vc = [[ReactNativeViewController alloc] initWithModuleName:component properties:properties];
    CKAsyncMainQueue(^{
        [gAppMgr.navModel.curNavCtrl pushViewController:vc animated:YES];
    });
}

RCT_EXPORT_METHOD(setInteractivePopGestureRecognizerDisable:(BOOL)disable) {
    CKAsyncMainQueue(^{
        if ([gAppMgr.navModel.curNavCtrl.topViewController isKindOfClass:[ReactNativeViewController class]]) {
            ReactNativeViewController *vc = (ReactNativeViewController *)gAppMgr.navModel.curNavCtrl.topViewController;
            vc.router.disableInteractivePopGestureRecognizer = disable;
        }
    });
}


RCT_EXPORT_METHOD(setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated) {
    CKAsyncMainQueue(^{
        if ([gAppMgr.navModel.curNavCtrl.topViewController isKindOfClass:[ReactNativeViewController class]]) {
            ReactNativeViewController *vc = (ReactNativeViewController *)gAppMgr.navModel.curNavCtrl.topViewController;
            [vc setNavigationBarHidden:hidden animated:animated];
        }
        else {
            [gAppMgr.navModel.curNavCtrl setNavigationBarHidden:hidden animated:animated];
        }
    });
}

@end
