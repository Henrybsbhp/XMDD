//
//  DetailWebVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/21.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "DetailWebVC.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "WebViewJavascriptBridge.h"
#import "NavigationModel.h"
#import "SocialShareViewController.h"
#import "MyWebViewBridge.h"

typedef NS_ENUM(NSInteger, MenuItemsType) {
    menuItemsTypeShare                  = 0,
    menuItemsTypeCollection             = 1
};

@interface DetailWebVC () <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, strong) NavigationModel *navModel;

@property (nonatomic, strong) MyWebViewBridge* bridge;

@property (nonatomic, strong)NJKWebViewProgress * progressProxy;
@property (nonatomic, strong)NJKWebViewProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation DetailWebVC

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
    
    self.navModel.curNavCtrl = self.navigationController;
    
    [self setupSignalsForLogin];
    
    [self setupProcessView];
    
    [self.webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        [self.webView loadRequest:self.request];
    });
    
    [self setupBridge];
}

- (void)setupSignalsForLogin
{
    @weakify(self);
    [[[RACObserve(gAppMgr, myUser) distinctUntilChanged] skip:1] subscribeNext:^(JTUser *user) {
        @strongify(self);
        [self.bridge setUserTokenHandler];
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

- (void)setupBridge
{
    self.bridge = [[MyWebViewBridge alloc] initBridgeWithWebView:self.webView andDelegate:self.progressProxy];
    
    //右上角菜单按钮设置
    [self.bridge.myBridge registerHandler:@"setOptionMenu" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSArray * menuArr = data;
        if (menuArr.count == 1) {
            self.navigationItem.rightBarButtonItem = [self.bridge setSingleMenu:[menuArr safetyObjectAtIndex:0]];
        }
        else {
            
        }
    }];
    
    //点击查看大图
    [self.bridge registerShowImage];
    
    //上传地理位置
    [self.bridge registerSetPosition];
    
//    //上传单张图片
//    [self.bridge.myBridge registerHandler:@"uploadSingleImage" handler:^(id data, WVJBResponseCallback responseCallback) {
//        
//    }];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
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
    
    [self.bridge setUserTokenHandler];
    
    if (self.webView.canGoBack) {
        [self setupLeftBtns];
    }
    else {
        [self setupLeftSingleBtn];
    }
}

- (void)setupLeftSingleBtn {
    UIBarButtonItem *back = [UIBarButtonItem webBackButtonItemWithTarget:self action:@selector(actionNewBack)];
    NSArray * backBtnArr = [[NSArray alloc] initWithObjects:back, nil];
    self.navigationItem.leftBarButtonItems = backBtnArr;
}

- (void)setupLeftBtns {
    UIBarButtonItem *back = [UIBarButtonItem webBackButtonItemWithTarget:self action:@selector(actionNewBack)];
    UIBarButtonItem *close = [UIBarButtonItem closeButtonItemWithTarget:self action:@selector(actionCloseWeb)];
    NSArray * backBtnArr = [[NSArray alloc] initWithObjects:back, close, nil];
    self.navigationItem.leftBarButtonItems =backBtnArr;
}

- (void)actionNewBack {
    NSString * returnBackStr = [self.webView stringByEvaluatingJavaScriptFromString:@"returnBackTest();"];
    if(returnBackStr) {
        [self.bridge.myBridge callHandler:@"returnBackHandler" data:nil responseCallback:^(id response) {
            DebugLog(@"%@", response);
            NSDictionary * dic = response;
            if ([dic boolParamForName:@"isFirstPage"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
    else {
        [self.webView goBack];
    }
}

- (void)actionCloseWeb {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
