//
//  HKNavigationController.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKNavigationController.h"

@implementation HKNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (IOSVersionGreaterThanOrEqualTo(@"7.0")) {
        self.navigationBar.translucent = NO;
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}


#pragma mark - Override
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    if (self.viewControllers.count > 1) {
        UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:viewController action:@selector(actionBack:)];
        [viewController.navigationItem setLeftBarButtonItem:back animated:animated];
    }
}

@end

@implementation UIViewController (HKNavigationController)

- (void)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
