//
//  JTNavigationController.m
//  EasyPay
//
//  Created by jiangjunchen on 14/10/27.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "JTNavigationController.h"
#import "CKKit.h"

@interface JTNavigationController ()

@end

@implementation JTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _shouldAllowInteractivePopGestureRecognizer = YES;
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
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        rootViewController.jtnavCtrl = self;
    }
    return self;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.jtnavCtrl = self;
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
        self.interactivePopGestureRecognizer.enabled = self.shouldAllowInteractivePopGestureRecognizer;
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
@dynamic jtnavCtrl;

static char s_navctrlKey;

- (void)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setJtnavCtrl:(JTNavigationController *)jtnavCtrl
{
    objc_setAssociatedObject(self, &s_navctrlKey, jtnavCtrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JTNavigationController *)jtnavCtrl
{
    return objc_getAssociatedObject(self, &s_navctrlKey);
}

@end
