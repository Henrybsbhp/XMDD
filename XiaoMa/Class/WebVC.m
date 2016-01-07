//
//  WebVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "WebVC.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "NavigationModel.h"

@interface WebVC ()<NJKWebViewProgressDelegate>
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong)NJKWebViewProgress * progressProxy;
@property (nonatomic, strong)NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NavigationModel *navModel;
@property (nonatomic, strong) UIBarButtonItem *originBackButton;
@property (nonatomic, strong) UIBarButtonItem *webBackButton;
@end

@implementation WebVC

- (void)dealloc
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.request];
    DebugLog(@"WebVC dealloc ~");
}

- (void)awakeFromNib
{
    self.navModel = [[NavigationModel alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.originBackButton = self.navigationItem.leftBarButtonItem;
    self.webBackButton = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionWebBack:)];
    self.navModel.curNavCtrl = self.navigationController;
    [self setupProcessView];
    [self.webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    self.webView.scalesPageToFit = YES;
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        [self.webView loadRequest:self.request];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UINavigationItem *)navigationItem
{
    if (self.parentViewController) {
        return [self.parentViewController navigationItem];
    }
    return [super navigationItem];
}

- (void)resetBackButton
{
    if (self.autoShowBackButton && [self.webView canGoBack]) {
        self.navigationItem.leftBarButtonItem = self.webBackButton;
    }
    else if (self.navigationItem.leftBarButtonItem != self.originBackButton) {
        self.navigationItem.leftBarButtonItem = self.originBackButton;
    }
}

- (void)setupProcessView
{
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    _webView.delegate = _progressProxy;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progress = 0;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionWebBack:(id)sender
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
        [self resetBackButton];
    }
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    NSString *title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0) {
        CKAsyncMainQueue(^{
            self.navigationItem.title = title;
        });
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DebugLog(@"%@ WebViewLoadError:%@\n,error=%@", kErrPrefix, webView.request.URL, error);
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    self.webView.scrollView.contentSize = self.webView.frame.size;
    if ((error.code >= 400 && error.code < 600) || error.code == -1009) {
        [gToast showError:kDefErrorPormpt];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    if ([url hasPrefix:@"xmdd://"]) {
        [self.navModel pushToViewControllerByUrl:url];
        return NO;
    }                      
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DebugLog(@"%@ WebViewStartLoad:%@", kReqPrefix, webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DebugLog(@"%@ WebViewFinishLoad:%@", kRspPrefix, webView.request.URL);
    [self resetBackButton];
}
@end
