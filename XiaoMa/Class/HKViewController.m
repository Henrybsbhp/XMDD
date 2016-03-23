//
//  HKViewController.m
//  XiaoMa
//
//  Created by jt on 16/1/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"

#define SuperClassName NSStringFromClass([self class])

@interface HKViewController ()

@end

@implementation HKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)actionBack:(id)sender
{
    if (self.prevVC) {
        [self.navigationController popToViewController:self.prevVC animated:YES];
    }
    else {
        [super actionBack:sender];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
