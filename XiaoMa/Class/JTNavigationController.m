//
//  JTNavigationController.m
//  EasyPay
//
//  Created by jiangjunchen on 14/10/27.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "JTNavigationController.h"
#import <CKKit.h>

@interface JTNavigationController ()

@end

@implementation JTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (IOSVersionGreaterThanOrEqualTo(@"7.0")) {
        self.navigationBar.translucent = NO;
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Rotation
-(NSUInteger)supportedInterfaceOrientations {
    UIViewController *top = self.topViewController;
    return top.supportedInterfaceOrientations;
}

-(BOOL)shouldAutorotate {
    UIViewController *top = self.topViewController;
    return [top shouldAutorotate];
}

#pragma mark - Override
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    if (self.viewControllers.count > 1) {
        UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:viewController action:@selector(actionBack:)];
        [viewController.navigationItem setLeftBarButtonItem:back animated:animated];
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = YES;
            self.interactivePopGestureRecognizer.delegate = (id)viewController;
        }
    }
}

@end

@implementation UIViewController (NavigationController)

- (void)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
