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

#pragma mark - Action
- (void)actionBack:(id)sender
{
    if (self.insModel.originVC) {
        [self.navigationController popToViewController:self.insModel.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
