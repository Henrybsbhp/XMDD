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
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@end

@implementation CommissionViewController
- (void)dealloc
{
    DebugLog(@"CommissionViewController dealloc ~");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [[self.actionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [MobClick event:@"rp128-2"];
        
        [gPhoneHelper makePhone:@"4007111111" andInfo:@"协办电话：4007-111-111"];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp128"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp128"];
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
    
    [MobClick event:@"rp128-1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        CommissionCouponViewController * vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionCouponViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
