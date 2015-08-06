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

@interface WebVC ()<NJKWebViewProgressDelegate>
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic,strong)NJKWebViewProgress * progressProxy;
@property (nonatomic,strong)NJKWebViewProgressView *progressView;

@end

@implementation WebVC

- (void)dealloc
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)setupProcessView
{
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
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
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    self.webView.scrollView.contentSize = self.webView.frame.size;
    [gToast showError:kDefErrorPormpt];
}
@end
