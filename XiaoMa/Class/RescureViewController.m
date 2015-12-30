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
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@end

@implementation RescureViewController

- (void)dealloc
{
    DebugLog(@"RescureViewController dealloc!");
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupNavigationBar];
    [[self.actionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [MobClick event:@"rp127-2"];
        [gPhoneHelper makePhone:@"4007111111" andInfo:@"救援电话：4007-111-111"];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp127"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp127"];
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
    [MobClick event:@"rp127-1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        RescueCouponViewController * vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueCouponViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
