//
//  RCTHKRefreshControl.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTHKRefreshControl.h"
#import <RCTUIManager.h>
#import <RCTScrollView.h>
#import <RCTEventEmitter.h>
#import "HKRefreshControl.h"

@implementation RCTHKRefreshControl

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return self.bridge.uiManager.methodQueue;
}

RCT_EXPORT_METHOD(configure:(nonnull NSNumber *)reactTag
                  options:(NSDictionary *)options
                  callback:(RCTResponseSenderBlock)callback) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactTag];
        if (!view) {
            RCTLogError(@"Cannot find view with tag #%@", reactTag);
            return;
        }
        
        UIScrollView *scrollView = ((RCTScrollView *)view).scrollView;
        HKRefreshControl *refreshControl = [[HKRefreshControl alloc] initWithScrollView:scrollView];
        refreshControl.tag = [reactTag integerValue]; // Maybe something better
        [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        
        callback(@[[NSNull null], reactTag]);
    }];
}

RCT_EXPORT_METHOD(beginRefreshing:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactTag];
        if (!view) {
            RCTLogError(@"Cannot find view with tag #%@", reactTag);
            return;
        }
        
        UIScrollView *scrollView = ((RCTScrollView *)view).scrollView;

        HKRefreshControl *refreshControl = [scrollView viewWithTag:[reactTag integerValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl beginRefreshing];
        });
    }];
}

RCT_EXPORT_METHOD(endRefreshing:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactTag];
        if (!view) {
            RCTLogError(@"Cannot find view with tag #%@", reactTag);
            return;
        }
        
        UIScrollView *scrollView = ((RCTScrollView *)view).scrollView;
        
        HKRefreshControl *refreshControl = [scrollView viewWithTag:[reactTag integerValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
        });
    }];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"dropViewDidBeginRefreshing"];
}

- (void)dropViewDidBeginRefreshing:(HKRefreshControl *)refreshControl {

    [self sendEventWithName:@"dropViewDidBeginRefreshing" body:@(refreshControl.tag)];
}


@end
