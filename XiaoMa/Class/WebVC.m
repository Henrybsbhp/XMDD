//
//  WebVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "WebVC.h"

@interface WebVC ()
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;
@end

@implementation WebVC

- (void)dealloc
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:self.request];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
