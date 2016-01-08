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
    
    CLS_LOG(@"%@ viewDidLoad",SuperClassName);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CLS_LOG(@"%@ viewWillAppear",SuperClassName);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CLS_LOG(@"%@ viewDidAppear",SuperClassName);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    CLS_LOG(@"%@ viewWillDisappear",SuperClassName);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    CLS_LOG(@"%@ viewDidDisappear",SuperClassName);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    CLS_LOG(@"%@ didReceiveMemoryWarning",SuperClassName);
}

@end
