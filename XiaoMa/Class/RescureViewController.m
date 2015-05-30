//
//  RescureViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "RescureViewController.h"
#import "RescueCouponViewController.h"

@interface RescureViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (nonatomic, strong) NSURLRequest *request;
@end

@implementation RescureViewController

- (void)dealloc
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [self.webView loadRequest:self.request];
    
    [[self.actionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [gPhoneHelper makePhone:@"4007111111" andInfo:@"立刻申请救援"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    RescueCouponViewController * vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueCouponViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
