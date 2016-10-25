//
//  MutualInsHomeAdVC.m
//  XiaoMa
//
//  Created by fuqi on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsHomeAdVC.h"
#import "MutualInsVC.h"
#import "MutInsCalculatePageVC.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface MutualInsHomeAdVC()<NJKWebViewProgressDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *calculateBtn;
@property (weak, nonatomic) IBOutlet UIButton *mutualInsBtn;

@property (nonatomic, strong) NJKWebViewProgress * progressProxy;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;

@end

@implementation MutualInsHomeAdVC

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self changeUserAgent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self setupProcessView];
    
    NSString * urlStr;
#if XMDDEnvironment==0
    urlStr = @"http://dev01.xiaomadada.com/apphtml/huzhujieshao-app.html";
#elif XMDDEnvironment==1
    urlStr = @"http://dev.xiaomadada.com/apphtml/huzhujieshao-app.html";
#else
    urlStr = @"http://www.xiaomadada.com/apphtml/huzhujieshao-app.html";
#endif
    
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}


#pragma mark - SetupUI
- (void)setupUI
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
    
    self.calculateBtn.layer.cornerRadius = 5;
    self.calculateBtn.layer.masksToBounds = YES;
    self.mutualInsBtn.layer.cornerRadius = 5;
    self.mutualInsBtn.layer.masksToBounds = YES;
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
    [MobClick event:@"hzjieshao" attributes:@{@"navi":@"back"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionJumpToMutualInsVC:(id)sender
{
    [MobClick event:@"hzjieshao" attributes:@{@"dibu":@"jiaru"}];
    MutualInsVC *vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsVC"];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)actionJumpToMutInsCalculateVC:(id)sender
{
    [MobClick event:@"hzjieshao" attributes:@{@"dibu":@"feiyongshisuan"}];
    MutInsCalculatePageVC *vc = [UIStoryboard vcWithId:@"MutInsCalculatePageVC" inStoryboard:@"MutualInsJoin"];
    vc.sensorChannel = @"apphzxuanchuan";
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    [self.router.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Utilitly

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view stopActivityAnimation];
    DebugLog(@"%@ WebViewLoadError:%@\n,error=%@", kErrPrefix, webView.request.URL, error);
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    self.webView.scrollView.contentSize = self.webView.frame.size;
    [gToast showError:kDefErrorPormpt];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DebugLog(@"%@ WebViewStartLoad:%@", kReqPrefix, webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.hidden = NO;
    
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0) {
        CKAsyncMainQueue(^{
            self.navigationItem.title = title;
        });
    }
    
    DebugLog(@"%@ WebViewFinishLoad:%@", kRspPrefix, webView.request.URL);
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:0.5+progress*0.5 animated:YES];
}

#pragma Utilitly
- (void)changeUserAgent
{
    UIWebView * webview = [[UIWebView alloc] init];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * userAgent = [webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    userAgent = userAgent ?: @"";
    
    if ([userAgent rangeOfString:@"XmddApp"].location == NSNotFound)
    {
        NSString * newUserAgent = [userAgent append:[NSString stringWithFormat:@" XmddApp(%@/%@)",@"XMDD",version]];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    }
}

@end
