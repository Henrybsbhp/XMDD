//
//  CommissionViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionViewController.h"

@interface CommissionViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@end

@implementation CommissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    
    [[self.actionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [gPhoneHelper makePhone:@"4007111111" andInfo:@"立刻申请代办"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
