//
//  InsAppointmentSuccessVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/19.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsAppointmentSuccessVC.h"

@interface InsAppointmentSuccessVC ()

@end

@implementation InsAppointmentSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp1011"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp1011"];
}
#pragma mark - Action
- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1011-1"];
    if (self.insModel.originVC) {
        [self.navigationController popToViewController:self.insModel.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
