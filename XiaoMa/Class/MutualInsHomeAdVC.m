//
//  MutualInsHomeAdVC.m
//  XiaoMa
//
//  Created by fuqi on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsHomeAdVC.h"
#import "MutualInsVC.h"

@interface MutualInsHomeAdVC()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation MutualInsHomeAdVC

- (void)viewDidLoad
{
    [self setupUI];
    
    NSString * urlStr;
#if XMDDEnvironment==0
    urlStr = @"http://dev01.xiaomadada.com/apphtml/huzhujieshao.html ";
#elif XMDDEnvironment==1
    urlStr = @"http://dev.xiaomadada.com/apphtml/huzhujieshao.html ";
#else
    urlStr = @"http://www.xiaomadada.com/apphtml/huzhujieshao.html ";
#endif
    
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    });
}


#pragma mark - Utilitly
- (void)setupUI
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
    
    @weakify(self)
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        MutualInsVC *vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    DebugLog(@"%@ WebViewStartLoad:%@", kReqPrefix, webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view stopActivityAnimation];
    self.webView.hidden = NO;
    
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0) {
        CKAsyncMainQueue(^{
            self.navigationItem.title = title;
        });
    }
    
    DebugLog(@"%@ WebViewFinishLoad:%@", kRspPrefix, webView.request.URL);
}

@end
