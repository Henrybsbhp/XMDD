//
//  InsuranceDirectSellingVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceDirectSellingVC.h"
#import "InsuranceInfoSubmitingVC.h"

#define kInsuranceDirectSellingUrl  @"http://www.xiaomadada.com/apphtml/chexianzhixiao.html"

@interface InsuranceDirectSellingVC ()

@end

@implementation InsuranceDirectSellingVC

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    self.url = kInsuranceDirectSellingUrl;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp131"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"rp131"];
}

#pragma mark - Action
- (IBAction)actionBuy:(id)sender {
    [MobClick event:@"rp131-2"];
    InsuranceInfoSubmitingVC *vc = [UIStoryboard vcWithId:@"InsuranceInfoSubmitingVC" inStoryboard:@"Insurance"];
    vc.submitModel = InsuranceInfoSubmitForDirectSell;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionMakeCall:(id)sender {
    [MobClick event:@"rp131-1"];
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"咨询电话：4007-111-111"];
}

- (void)actionBack:(id)sender {
    [MobClick event:@"rp131-3"];
    [super actionBack:sender];
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
