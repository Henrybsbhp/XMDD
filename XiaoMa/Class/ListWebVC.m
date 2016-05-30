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
#import "GetAreaByPcdOp.h"


@interface ListWebVC () <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, strong) NavigationModel *navModel;

@property (nonatomic, strong) NJKWebViewProgress * progressProxy;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) MyWebViewBridge* myBridge;

@property (nonatomic, strong) GetAreaByPcdOp *areaInfo;

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
    self.view.backgroundColor = kBackgroundColor;
    
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

- (void)observeUserInfo
{
    @weakify(self);
    [[[[RACObserve(gAppMgr, myUser) distinctUntilChanged] skip:1] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(JTUser *user) {
        
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
    @weakify(self);
    //获取反地理位置编码信息
    [[[[[[gMapHelper rac_getInvertGeoInfo] initially:^{
        
        @strongify(self);
        //设置开始进度到15%
        [self.progressView setProgress:0.15 animated:YES];
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal return:nil];
    }]  flattenMap:^RACStream *(AMapReGeocode *reGeocode) {
        
        @strongify(self);
        //获取到反地理位置信息，设置进度到40%
        [self.progressView setProgress:0.35 animated:YES];
        if (!reGeocode) {
            return [RACSignal return:nil];
        }
        //获取区域编码
        GetAreaByPcdOp *op = [GetAreaByPcdOp operation];
        op.req_province = reGeocode.addressComponent.province;
        op.req_city = reGeocode.addressComponent.city;
        op.req_district = reGeocode.addressComponent.district;
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
        [params safetySetObject:self.areaInfo.rsp_province.infoCode forKey:@"provincecode"];
        [params safetySetObject:self.areaInfo.rsp_city.infoCode forKey:@"citycode"];
        [params safetySetObject:self.areaInfo.rsp_district.infoCode forKey:@"areacode"];
        NSString * discoverUrl = [NavigationModel appendParams:params forUrl:DiscoverUrl];
        self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:discoverUrl]];
        
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
