//
//  MyWebViewBridge.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/22.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

@interface MyWebViewBridge : NSObject

@property (nonatomic, strong) WebViewJavascriptBridge* myBridge;

@property (nonatomic, assign) BOOL isNeedLogin;

@property (nonatomic, weak) UIViewController * targetVC;

- (instancetype)initBridgeWithWebView:(WVJB_WEBVIEW_TYPE *)webView andDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *) delegate withTargetVC:(UIViewController *)targetVC;

- (void)registerGetToken;

- (void)registerToastMsg;

- (void)registerSetPosition;

- (void)registerNetworkState;

- (void)registerCallPhone;

- (void)registerShowImage;

- (void)uploadImage;

///设置导航
- (void)registerNavigation;
///设置提示框
- (void)registerAlertVC;
///分享
- (void)registerShare;

- (void)registerLogin;

- (void)registerOpenView;
///网页调用App加一辆车
- (void)registerAddCar;

- (UIBarButtonItem *)setSingleMenu:(NSString *)singleBtn;

- (UIBarButtonItem *)setMultipleMenu:(NSArray *)btnArray;

@end
