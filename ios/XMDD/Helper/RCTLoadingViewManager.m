//
//  RCTLoadingViewManager.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTLoadingViewManager.h"
#import <RCTBridge.h>
#import <RCTUIManager.h>
#import "HKLoadingView.h"

@implementation RCTLoadingViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[HKLoadingView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(isAnimating, BOOL);
RCT_EXPORT_VIEW_PROPERTY(hidden, BOOL);

RCT_EXPORT_METHOD(startGifAnimating:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        HKLoadingView *loadingView = (HKLoadingView *)viewRegistry[reactTag];
        [loadingView startGifAnimating];
    }];
}

RCT_EXPORT_METHOD(startUIAnimating:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        HKLoadingView *loadingView = (HKLoadingView *)viewRegistry[reactTag];
        [loadingView startUIAnimating];
    }];
}

RCT_EXPORT_METHOD(startMONAnimating:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        HKLoadingView *loadingView = (HKLoadingView *)viewRegistry[reactTag];
        [loadingView startMONAnimating];
    }];
}

RCT_EXPORT_METHOD(startTYMAnimating:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        HKLoadingView *loadingView = (HKLoadingView *)viewRegistry[reactTag];
        [loadingView startTYMAnimating];
    }];
}

RCT_EXPORT_METHOD(stopAnimating:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        HKLoadingView *loadingView = (HKLoadingView *)viewRegistry[reactTag];
        [loadingView stopAnimating];
    }];
}

@end
