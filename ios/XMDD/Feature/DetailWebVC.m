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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIWindowDidRotateNotification" object:nil];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.request];
    DebugLog(@"DetailWebVC dealloc ~");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    self.navModel = [[NavigationModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
    
    @weakify(self)
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UIWindowDidRotateNotification" object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        @strongify(self)
        if ([note.userInfo[@"UIWindowOldOrientationUserInfoKey"] intValue] >= 3) {
            [self.navigationController.navigationBar sizeToFit];
            self.navigationController.navigationBar.frame = (CGRect){0, 0, self.view.frame.size.width, 64};
        }
        
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHex:@"#f4f4f4" alpha:1.0f];
    self.webView.backgroundColor = [UIColor colorWithHex:@"#f4f4f4" alpha:1.0f];
    self.navModel.curNavCtrl = self.navigationController;
    
    [self setupProcessView];
    
    [self setupLeftSingleBtn];
    
    [self changeUserAgent];
    
    [self.webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self setupBridge];
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        [self.webView loadRequest:self.request];
    });
}

- (void)requestUrl:(NSString *)url
{
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    CKAsyncMainQueue(^{
        
        [self.webView loadRequest:urlRequest];
    });
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
    self.bridge = [[MyWebViewBridge alloc] initBridgeWithWebView:self.webView andDelegate:self.progressProxy withTargetVC:self];
    
    //右上角分享菜单按钮设置
    [self setupShareItem];
    //右上角菜单按钮设置（与上面一句不会同时存在）
    [self setupRightNavItem];
    
    //弱提示框方法
    [self.bridge registerToastMsg];
    
    //点击查看大图
    [self.bridge registerShowImage];
    
    //上传地理位置
    [self.bridge registerSetPosition];
    
    //获取网络状态
    [self.bridge registerNetworkState];
    
    //打电话
    [self.bridge registerCallPhone];
    
    //上传单张图片
    [self.bridge uploadImage];
    
    //设置导航
    [self.bridge registerNavigation];
    
    //设置提示框
    [self.bridge registerAlertVC];
    
    //设置分享
    [self.bridge registerShare];
    
    /// 设置登录
    [self.bridge registerLogin];
    
    /// 设置登录
    [self.bridge registerOpenView];
}

- (void)setupShareItem
{
    @weakify(self);
    [self.bridge.myBridge registerHandler:@"setOptionMenu" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        NSArray * menuArr = data;
        if (menuArr.count == 1) {
            self.navigationItem.rightBarButtonItem = [self.bridge setSingleMenu:[menuArr safetyObjectAtIndex:0]];
        }
        else {
            self.navigationItem.rightBarButtonItem = [self.bridge setMultipleMenu:menuArr];
        }
        responseCallback(nil);
    }];
}

- (void)setupRightNavItem
{
    @weakify(self);
    [self.bridge.myBridge registerHandler:@"barNavBtn" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        NSDictionary * dic = data;
        
        NSString * triggerId = [dic stringParamForName:@"triggerId"];
        NSString * icon = [dic stringParamForName:@"icon"];
        NSString * title = [dic stringParamForName:@"title"];
        NSString * type = [dic stringParamForName:@"type"];

        [self setupRightSingleBtn:type andBtnTitle:title andIconUrl:icon andTriggedId:triggerId];

        responseCallback(nil);
    }];
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    DebugLog(@"webViewProgress:%f", progress);
    
    [_progressView setProgress:progress animated:YES];
    
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0) {
        CKAsyncMainQueue(^{
            self.navigationItem.title = title;
        });
    }
    
    [self.bridge registerGetToken];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DebugLog(@"%@ WebViewLoadError:%@\n,error=%@", kErrPrefix, webView.request.URL, error);
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    self.webView.scrollView.contentSize = self.webView.frame.size;
    NSString * domain = [NSString stringWithFormat:@"%@[%ld]",kDefErrorPormpt,(long)error.code];
    [gToast showError:domain];
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
}


#pragma mark - Setup
- (void)setupLeftSingleBtn {
    UIBarButtonItem *back = [UIBarButtonItem webBackButtonItemWithTarget:self action:@selector(actionNewBack)];
    NSArray * backBtnArr = [[NSArray alloc] initWithObjects:back, nil];
    self.navigationItem.leftBarButtonItems = backBtnArr;
}

- (void)setupLeftBtns {
    UIBarButtonItem *back = [UIBarButtonItem webBackButtonItemWithTarget:self action:@selector(actionNewBack)];
    UIBarButtonItem *close = [UIBarButtonItem closeButtonItemWithTarget:self action:@selector(actionCloseWeb)];
    NSArray * backBtnArr = [[NSArray alloc] initWithObjects:back, close, nil];
    self.navigationItem.leftBarButtonItems = backBtnArr;
}


- (void)setupRightSingleBtn:(NSString *)type andBtnTitle:(NSString *)btnTitle
                 andIconUrl:(NSString *)urlStr andTriggedId:(NSString *)triggerId{
    
    __block UIBarButtonItem *right;
    if ([type isEqualToString:@"0"]) {
        right = [[UIBarButtonItem alloc] initWithTitle:btnTitle style:UIBarButtonItemStylePlain target:self action:@selector(actionRightItemHandle:)];
        [right setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:16.0]} forState:UIControlStateNormal];
    }
    else if ([type isEqualToString:@"1"])
    {
        right = [[UIBarButtonItem alloc] initWithTitle:btnTitle style:UIBarButtonItemStylePlain target:self action:@selector(actionRightItemHandle:)];
        [right setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:16.0]} forState:UIControlStateNormal];
        
        [[gMediaMgr rac_getImageByUrl:urlStr withType:ImageURLTypeOrigin defaultPic:@"" errorPic:@""] subscribeNext:^(UIImage * x) {
            
            if (!x)
            {
                return ;
            }
            CKAsyncMainQueue(^{
               
                right = [[UIBarButtonItem alloc] initWithImage:x style:UIBarButtonItemStylePlain target:self action:@selector(actionRightItemHandle:)];
                right.customObject = triggerId;
                self.navigationItem.rightBarButtonItem = right;
                
            });
        }];
    }
    
    right.customObject = triggerId;
    self.navigationItem.rightBarButtonItem = right;
}








#pragma mark - Action
- (void)actionCloseWeb {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionNewBack {
    NSString * returnBackStr = [self.webView stringByEvaluatingJavaScriptFromString:@"thirdPartyPageTest();"];
    if(returnBackStr.length > 0) {
        [self.bridge.myBridge callHandler:@"returnBackHandler" data:nil responseCallback:^(id response) {
            NSDictionary * dic = response;
            if ([dic boolParamForName:@"isFirstPage"]) {
                [self popViewController];
            }
            else {
                [self setupLeftBtns];
            }
        }];
    }
    else {
        if (self.webView.canGoBack) {
            [self setupLeftBtns];
            [self.webView goBack];
        }
        else {
            [self popViewController];
        }
    }
}

- (void)popViewController
{
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionRightItemHandle:(id)sender
{
    NSObject * obj = (NSObject *)sender;
    NSDictionary * rDict;
    if (obj.customObject)
    {
        rDict = @{@"triggerId":obj.customObject};
    }
    NSString * dataStr = [rDict jsonEncodedString];
    [self.bridge.myBridge callHandler:@"barNavBtnHandler" data:dataStr responseCallback:^(id response) {
    }];
}

#pragma mark - Utilitly
- (void)changeUserAgent
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * userAgent = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    userAgent = userAgent ?: @"";
    
    if ([userAgent rangeOfString:@"XMDD"].location == NSNotFound)
    {
        NSString * newUserAgent = [userAgent append:[NSString stringWithFormat:@" %@/%@",@"XMDD",version]];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    }
}
@end
