//
//  InsuranceDirectSellingVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceDirectSellingVC.h"
#import "InsuranceInfoSubmitingVC.h"

#define kInsuranceDirectSellingUrl  @"http://www.xiaomadada.com/apphtml/aichebao.html"

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

#pragma mark - Action
- (IBAction)actionBuy:(id)sender {
    InsuranceInfoSubmitingVC *vc = [UIStoryboard vcWithId:@"InsuranceInfoSubmitingVC" inStoryboard:@"Insurance"];
    vc.submitModel = InsuranceInfoSubmitForDirectSell;
    [self.navigationController pushViewController:vc animated:YES];
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
