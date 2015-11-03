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

- (instancetype)initBridgeWithWebView:(WVJB_WEBVIEW_TYPE *)webView andDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *) delegate;

- (void)registerGetToken;

- (void)registerToastMsg;

- (void)registerSetPosition;

- (void)registerNetworkState;

- (void)registerCallPhone;

- (void)registerShowImage;

- (void)uploadImage:(UIViewController *)superVC;

- (UIBarButtonItem *)setSingleMenu:(NSString *)singleBtn;

@end
