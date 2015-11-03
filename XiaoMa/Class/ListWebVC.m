//
//  ListWebVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/21.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "ListWebVC.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "WebViewJavascriptBridge.h"
#import "NavigationModel.h"
#import "DetailWebVC.h"
#import "MyWebViewBridge.h"


@interface ListWebVC () <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, strong) NavigationModel *navModel;

@property (nonatomic, strong)NJKWebViewProgress * progressProxy;
@property (nonatomic, strong)NJKWebViewProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) MyWebViewBridge* myBridge;

@end

@implementation ListWebVC

- (void)awakeFromNib
{
    self.navModel = [[NavigationModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"rp202"];
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"rp202"];
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupProcessView];
    
    [self.webView.scrollView.refreshView addTarget:self action:@selector(reloadwebView) forControlEvents:UIControlEventValueChanged];
    
    [self.webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    self.webView.scalesPageToFit = YES;
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:DiscoverUrl]];
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        [self.webView loadRequest:self.request];
    });
    
    self.myBridge = [[MyWebViewBridge alloc] initBridgeWithWebView:self.webView andDelegate:self.progressProxy];
    
    [self.myBridge registerGetToken];
    
    [self.myBridge registerToastMsg];
}

- (void)setupProcessView
{
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progress = 0;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)reloadwebView
{
    //reload方法在第一次读取失败的时候会reload失败
    [self.webView loadRequest:self.request];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.webView.scrollView.refreshView endRefreshing];
    
    DebugLog(@"%@ WebViewLoadError:%@\n,error=%@", kErrPrefix, webView.request.URL, error);
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    self.webView.scrollView.contentSize = self.webView.frame.size;
    if ((error.code >= 400 && error.code < 600) || error.code == -1009) {
        [gToast showError:kDefErrorPormpt];
    }
    else {
        [gToast showError:@"无法连接到服务器"];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    if (![url isEqualToString:DiscoverUrl]) {
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.url = url;
        [self.navigationController pushViewController:vc animated:YES];
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
    
    [self.webView.scrollView.refreshView endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
