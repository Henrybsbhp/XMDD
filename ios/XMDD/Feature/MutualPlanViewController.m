//
//  MutualPlanViewController.m
//  XMDD
//
//  Created by fuqi on 16/9/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualPlanViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "WebViewJavascriptBridge.h"
#import "NavigationModel.h"
#import "DetailWebVC.h"
#import "MyWebViewBridge.h"
#import "GetAreaByPcdOp.h"
#import "CBAutoScrollLabel.h"

#if XMDDEnvironment==0
    #define MutualPlanTabUrl @"http://dev01.xiaomadada.com/paaweb/general/huzhuload"
#elif XMDDEnvironment==1
    #define MutualPlanTabUrl @"http://dev.xiaomadada.com/paaweb/general/huzhuload"
#else
    #define MutualPlanTabUrl @"https://www.xiaomadada.com/paaweb/general/huzhuload"
#endif

@interface MutualPlanViewController ()<UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic,strong) NavigationModel *navModel;

@property (nonatomic,strong) NJKWebViewProgress * progressProxy;
@property (nonatomic,strong) NJKWebViewProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *roundLb;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic,strong) NSURLRequest *request;

@property (nonatomic,strong) MyWebViewBridge* myBridge;

@property (nonatomic,strong) GetAreaByPcdOp *areaInfo;

@end

@implementation MutualPlanViewController

- (void)dealloc
{
    DebugLog(@"MutualPlanViewController dealloc ~");
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
    self.view.backgroundColor = kBackgroundColor;
    
    [self setupUI];
    [self observeUserInfo];
    [self setupProcessView];
    
    self.navModel.curNavCtrl = self.navigationController;
    
    [self.webView.scrollView.refreshView addTarget:self action:@selector(reloadwebView) forControlEvents:UIControlEventValueChanged];
    
    [self.webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    self.webView.scalesPageToFit = YES;
    
    
    self.myBridge = [[MyWebViewBridge alloc] initBridgeWithWebView:self.webView andDelegate:self.progressProxy withTargetVC:self];
    [self.myBridge registerGetToken];
    [self.myBridge registerToastMsg];
    
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        [self reloadwebView];
    });
}

- (void)setupUI
{
    self.topView.backgroundColor = HEXCOLOR(@"#ffd97c");
    self.roundLb.textColor = HEXCOLOR(@"#ff7428");
    self.roundLb.font = [UIFont systemFontOfSize:14];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] init];
    [self.topView addGestureRecognizer:tapGesture];
    
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        
        if (gAppMgr.huzhuTabUrl.length)
        {
            [self.navModel pushToViewControllerByUrl:gAppMgr.huzhuTabUrl];
        }
    }];
}


- (void)observeUserInfo
{
    @weakify(self);
    [[[[RACObserve(gAppMgr, myUser) distinctUntilChanged] skip:1] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(JTUser *user) {
         
         @strongify(self);
         [self reloadwebView];
     }];
    
    [[[RACObserve(gAppMgr, huzhuTabTitle) distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString * title) {
        
        @strongify(self);
        [UIView animateWithDuration:0.5 animations:^{
           
            self.topViewHeightConstraint.constant = title.length ? 35 : 0;
        }];
        
        self.roundLb.text = title;
    }];
    
    [[[RACObserve(gAppMgr, huzhuTabUrl) distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString * url) {
        
        @strongify(self);
        self.arrowImage.hidden = !url.length;
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
    @weakify(self);
    //获取反地理位置编码信息
    [[[[[[gMapHelper rac_getUserLocationAndInvertGeoInfoWithAccuracy:kCLLocationAccuracyKilometer] initially:^{
        
        @strongify(self);
        //设置开始进度到15%
        [self.progressView setProgress:0.15 animated:YES];
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal return:nil];
    }]  flattenMap:^RACStream *(RACTuple * tuple) {
        
        @strongify(self);
        //获取到反地理位置信息，设置进度到40%
        [self.progressView setProgress:0.35 animated:YES];
        if (!tuple.second) {
            return [RACSignal return:nil];
        }
        //获取区域编码
        GetAreaByPcdOp *op = [GetAreaByPcdOp operation];
        op.req_province = gMapHelper.addrComponent.province;
        op.req_city = gMapHelper.addrComponent.city;
        op.req_district = gMapHelper.addrComponent.district;
        return [[op rac_postRequest] catch:^RACSignal *(NSError *error) {
            return [RACSignal return:nil];
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(GetAreaByPcdOp *op) {
        
        @strongify(self);
        //从服务器获取到地理位置的编码，设置进度到50%
        [self.progressView setProgress:0.5 animated:YES];
        if (op) {
            self.areaInfo = op;
        }
        
        //拼接url
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params safetySetObject:@(self.areaInfo.rsp_province.infoId) forKey:@"provinceid"];
        [params safetySetObject:@(self.areaInfo.rsp_city.infoId) forKey:@"cityid"];
        [params safetySetObject:@(self.areaInfo.rsp_district.infoId) forKey:@"areaid"];
        [params safetySetObject:gNetworkMgr.token ?: @"" forKey:@"token"];
        NSString * mutualPlanUrl = [NavigationModel appendParams:params forUrl:MutualPlanTabUrl];
        self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:mutualPlanUrl]];
        
        //reload方法在第一次读取失败的时候会reload失败,所以重新调用loadRequest
        //避免横条滚动
        //加上刷新的时候会闪一下(已解决)
        self.webView.scrollView.contentSize = CGSizeMake(self.webView.frame.size.width, self.webView.scrollView.contentSize.height);
        [self.webView loadRequest:self.request];
    }];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:0.5+progress*0.5 animated:YES];
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
    if (![url hasPrefix:MutualPlanTabUrl] && ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])) {
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
