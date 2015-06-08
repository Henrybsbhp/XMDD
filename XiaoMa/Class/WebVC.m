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

@interface WebVC ()<NJKWebViewProgressDelegate,UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
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
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
     [self setupProcessView];
    
     [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    // Do any additional setup after loading the view.
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
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
