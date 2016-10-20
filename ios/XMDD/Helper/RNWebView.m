//
//  RCTHKWebView.m
//  XMDD
//
//  Created by jiangjunchen on 16/10/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RNWebView.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "NavigationModel.h"

@interface RNWebView ()<NJKWebViewProgressDelegate, UIWebViewDelegate>
@property (nonatomic, strong)NJKWebViewProgress * progressProxy;
@property (nonatomic, strong)NJKWebViewProgressView *progressView;
@end

@implementation RNWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
        self.webView.delegate = _progressProxy;
        
        CGRect barFrame = CGRectMake(0, 0, frame.size.width, 2);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.progress = 0;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_progressView];
    }
    return self;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    if ([url hasPrefix:@"xmdd://"]) {
        [gAppMgr.navModel pushToViewControllerByUrl:url];
        return NO;
    }
    return [super webView: webView shouldStartLoadWithRequest: request navigationType: navigationType];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DebugLog(@"%@ WebViewLoadError:%@\n,error=%@", kErrPrefix, webView.request.URL, error);
    [super webView: webView didFailLoadWithError: error];
    if ((error.code >= 400 && error.code < 600) || error.code == -1009) {
        [gToast showError:kDefErrorPormpt];
    }
}
@end
