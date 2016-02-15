//
//  HKViewController.m
//  XiaoMa
//
//  Created by jt on 16/1/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"

#define SuperClassName NSStringFromClass([super class])

@interface HKViewController ()

@end

@implementation HKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HKCLSLog(@"%@ viewDidLoad",SuperClassName);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HKCLSLog(@"%@ viewWillAppear",SuperClassName);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HKCLSLog(@"%@ viewDidAppear",SuperClassName);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HKCLSLog(@"%@ viewWillDisappear",SuperClassName);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HKCLSLog(@"%@ viewDidDisappear",SuperClassName);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    HKCLSLog(@"%@ didReceiveMemoryWarning",SuperClassName);
}

@end
