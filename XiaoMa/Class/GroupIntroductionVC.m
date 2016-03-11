//
//  GroupIntroductionVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GroupIntroductionVC.h"
#import "AutoGroupInfoVC.h"

#define IntroUrl @"http://www.baidu.com"

@interface GroupIntroductionVC () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)joinAction:(id)sender;

@end

@implementation GroupIntroductionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.titleStr;
    
    self.webView.delegate = self;
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:IntroUrl]]];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.webView stopActivityAnimation];
    DebugLog(@"%@ WebViewLoadError:%@\n,error=%@", kErrPrefix, webView.request.URL, error);
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    self.webView.scrollView.contentSize = self.webView.frame.size;
    [gToast showError:kDefErrorPormpt];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.webView startActivityAnimationWithType:GifActivityIndicatorType];
    DebugLog(@"%@ WebViewStartLoad:%@", kReqPrefix, webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.webView stopActivityAnimation];
    DebugLog(@"%@ WebViewFinishLoad:%@", kRspPrefix, webView.request.URL);
}

- (IBAction)joinAction:(id)sender {
    AutoGroupInfoVC * vc = [UIStoryboard vcWithId:@"AutoGroupInfoVC" inStoryboard:@"MutualInsJoin"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
