//
//  CommissionViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionViewController.h"
#import "CommissionCouponViewController.h"

@interface CommissionViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@end

@implementation CommissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    
    [[self.actionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [gPhoneHelper makePhone:@"4007111111" andInfo:@"立刻申请代办"];
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
    CommissionCouponViewController * vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionCouponViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
