//
//  RescureViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "RescureViewController.h"
#import "RescueCouponViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface RescureViewController ()<NJKWebViewProgressDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@property (nonatomic,strong)NJKWebViewProgress * progressProxy;
@property (nonatomic,strong)NJKWebViewProgressView *progressView;

@end

@implementation RescureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupProcessView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    
    [[self.actionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [gPhoneHelper makePhone:@"4007111111" andInfo:@"立刻申请救援"];
    }];
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
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)setupNavigationBar
{
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"免费券" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(actionNavigationToCoupon)];
    [right setTitleTextAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                                    } forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)actionNavigationToCoupon
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        RescueCouponViewController * vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueCouponViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}
@end
