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

@property (nonatomic, strong) NJKWebViewProgress * progressProxy;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) MyWebViewBridge* myBridge;

@end

@implementation ListWebVC

- (void)dealloc
{
    DebugLog(@"ListWebVC dealloc ~");
}
- (void)awakeFromNib
{
    self.navModel = [[NavigationModel alloc] init];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self observeUserInfo];
    [self setupProcessView];
    
    self.navModel.curNavCtrl = self.navigationController;
    
    [self.webView.scrollView.refreshView addTarget:self action:@selector(reloadwebView) forControlEvents:UIControlEventValueChanged];
    
    [self.webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    self.webView.scalesPageToFit = YES;
    NSString * discoverUrl = [NavigationModel appendStaticParam:DiscoverUrl];
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:discoverUrl]];
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        [self.webView loadRequest:self.request];
    });
    
    self.myBridge = [[MyWebViewBridge alloc] initBridgeWithWebView:self.webView andDelegate:self.progressProxy];
    
    [self.myBridge registerGetToken];
    [self.myBridge registerToastMsg];
}

- (void)observeUserInfo
{
    @weakify(self);
    [[[RACObserve(gAppMgr, myUser) distinctUntilChanged] skip:1] subscribeNext:^(JTUser *user) {
        
        @strongify(self);
        [self reloadwebView];
    }];
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
    //reload方法在第一次读取失败的时候会reload失败,所以重新调用loadRequest
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentSize = CGSizeMake(self.webView.frame.size.width, self.webView.scrollView.contentSize.height);//避免横条滚动  //加上刷新的时候会闪一下(已解决)
        [self.webView loadRequest:self.request];
    });
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
    //self.webView.scrollView.contentInset = UIEdgeInsetsZero; //刷新失败，下拉动画瞬间消失
    self.webView.scrollView.contentSize = CGSizeMake(self.webView.frame.size.width, self.webView.scrollView.contentSize.height);
    NSString * domain = [NSString stringWithFormat:@"%@[%ld]",kDefErrorPormpt,(long)error.code];
    [gToast showError:domain];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    //屏蔽非法页面
    if (![url hasPrefix:DiscoverUrl] && ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])) {
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
    
    [self.webView.scrollView.refreshView endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
