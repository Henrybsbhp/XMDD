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
        
        __weak JTNavigationController *weakSelf = self;
        self.interactivePopGestureRecognizer.delegate = (id)weakSelf;
        self.delegate = (id)weakSelf;
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
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

//- (UIViewController *)popViewControllerAnimated:(BOOL)animated
//{
//    UIViewController * vc = [super popViewControllerAnimated:animated];
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES) {
//        self.interactivePopGestureRecognizer.enabled = NO;
//    }
//    return vc;
//}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    if ( gestureRecognizer == self.interactivePopGestureRecognizer )
    {
        if ( self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0] )
        {
            return NO;
        }
    }
    
    return YES;
}



@end

@implementation UIViewController (NavigationController)

- (void)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
