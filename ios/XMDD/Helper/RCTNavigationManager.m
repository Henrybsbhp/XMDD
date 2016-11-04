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
#import "CollectionChooseVC.h"
#import "PickInsCompaniesVC.h"
#import "ImagePickerVC.h"
#import <RCTConvert.h>
#import <RCTImageSource.h>

@implementation RCTNavigationManager

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(popToViewByRouteKey:(NSString *)key props:(NSDictionary *)props animated:(BOOL)animated
                  fail:(RCTResponseSenderBlock)callback) {
    CKNavigationController *nav = (CKNavigationController *)gAppMgr.navModel.curNavCtrl;
    CKRouter *route = [nav.routerList objectForKey:key];
    if (route && ![route.targetViewController isEqual:nav.topViewController]) {
        CKAsyncMainQueue(^{
            [nav popToViewController:route.targetViewController animated:YES];
            if (props && [route.targetViewController isKindOfClass:[ReactNativeViewController class]]) {
                ReactNativeViewController *rctvc = (ReactNativeViewController *)route.targetViewController;
                [rctvc.rctView.rctRootView.bridge enqueueJSCall:@"Notify" method:@"handle"
                                                           args:@[props] completion:nil];
            }
        });
    }
    callback(@[]);
}

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

RCT_EXPORT_METHOD(pushHref:(NSString *)href withProperties:(NSDictionary *)properties andAnimated:(BOOL)animated) {
    ReactNativeViewController *vc = [[ReactNativeViewController alloc] initWithHref:href properties:properties];
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

#pragma mark - ViewController
RCT_EXPORT_METHOD(presentPlateNumberProvincePicker:(RCTResponseSenderBlock)callback) {
    CKAsyncMainQueue(^{
        CollectionChooseVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"CollectionChooseVC"];
        HKNavigationController *nav = [[HKNavigationController alloc] initWithRootViewController:vc];
        vc.datasource = gAppMgr.getProvinceArray;
        [vc setSelectAction:^(NSDictionary *dict) {
            callback(@[dict]);
        }];
        [gAppMgr.navModel.curNavCtrl presentViewController:nav animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(pushInsuanceCompanyPicker:(RCTResponseSenderBlock)callback) {
    CKAsyncMainQueue(^{
        PickInsCompaniesVC *vc = [UIStoryboard vcWithId:@"PickInsCompaniesVC" inStoryboard:@"Car"];
        [vc setPickedBlock:^(NSString *name) {
            callback(@[name]);
        }];
        [gAppMgr.navModel.curNavCtrl pushViewController:vc animated:YES];
    });
}

RCT_EXPORT_METHOD(presentImagePicker:(UIImage *)exampleImage callback:(RCTResponseSenderBlock)callback) {
    CKAsyncMainQueue(^{
        ImagePickerVC * vc = [[ImagePickerVC alloc] init];
        vc.exampleImage = exampleImage;
        vc.targetVC = gAppMgr.navModel.curNavCtrl;
        vc.shouldCompressImage = NO;
        [vc setCompletedBlock:^(NSDictionary *info) {
            NSURL *url = info[UIImagePickerControllerReferenceURL];
            if (url) {
                UIImage *image = info[UIImagePickerControllerOriginalImage];
                callback(@[@{@"uri": url.absoluteString,
                             @"width": @(image.size.width),
                             @"height": @(image.size.height),
                             @"scale": @(image.scale)}]);
            }
        }];
        [vc show];
    });
}

@end
