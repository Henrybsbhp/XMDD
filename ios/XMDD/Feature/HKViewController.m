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
    NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if (index > 0 && index != NSNotFound) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
