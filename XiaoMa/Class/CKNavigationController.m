//
//  CKNavigationController.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKNavigationController.h"
#import "CKRouter.h"
#import <objc/runtime.h>

static char s_viewControllerRouterKey;

@implementation UIViewController (CKNavigator)
@dynamic router;

- (CKRouter *)router {
    CKRouter *routerObj = objc_getAssociatedObject(self, &s_viewControllerRouterKey);
    if (!routerObj) {
        routerObj = [CKRouter routerWithTargetViewController:self];
        objc_setAssociatedObject(self, &s_viewControllerRouterKey, routerObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return routerObj;
}

@end

@interface CKNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate, CKRouterDelegate> {
    CKList *_viewControllerStack;
}
@end

@implementation CKNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak id weakSelf = self;
    self.interactivePopGestureRecognizer.delegate = weakSelf;
    self.delegate = weakSelf;
}

- (void)awakeFromNib {
    [self resetForViewControllers:self.viewControllers];
}



- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    [super setViewControllers:viewControllers];
    [self resetForViewControllers:viewControllers];
}

#pragma mark - Override
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self enqueueViewController:rootViewController];
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self enqueueViewController:viewController];
    [super pushViewController:viewController animated:animated];
    if (animated) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)pushRouter:(nonnull CKRouter *)router animated:(BOOL)animated
{
    objc_setAssociatedObject(router.targetViewController, &s_viewControllerRouterKey, router, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self pushViewController:router.targetViewController animated:animated];
}

- (void)popToRouter:(nonnull CKRouter *)router animated:(BOOL)animated
{
    [self popToViewController:router.targetViewController animated:animated];
}

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.routerList removeObjectAtIndex:self.routerList.count-1];
    return [super popViewControllerAnimated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (index != NSNotFound) {
        [self.routerList removeObjectsFromIndex:index+1];
    }
    return [super popToViewController:viewController animated:animated];

}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    [self.routerList removeObjectsFromIndex:1];
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - RouterList
- (nonnull CKList *)routerList {
    if (_viewControllerStack) {
        _viewControllerStack = [[CKList alloc] init];
    }
    return _viewControllerStack;
}

- (void)resetForViewControllers:(NSArray *)viewControllers {
    [self.routerList removeAllObjects];
    for (UIViewController *vc in viewControllers) {
        [self enqueueViewController:vc];
    }
}

- (void)enqueueViewController:(UIViewController *)vc {
    CKRouter *router = vc.router;
    if (!router.userInfo) {
        router.userInfo = [self topViewController].router.userInfo;
    }
    [self.routerList addObject:router forKey:router.key];
    router.delegate = self;
    vc.title = vc.title ? vc.title : router.title;
}

- (void)updateViewControllersByRouterList {
    self.viewControllers = [[self.routerList allObjects] arrayByMapFilteringOperator:^id(CKRouter *obj) {
        return obj.targetViewController;
    }];
}

- (void)updateRouterListByViewControllers {
    NSArray *routers = [self.viewControllers arrayByMapFilteringOperator:^id(UIViewController *obj) {
        return obj.router;
    }];
    [self.routerList removeAllObjects];
    [self.routerList addObjectsFromArray:routers];
}
#pragma mark - Rotation
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *top = self.topViewController;
    return top.supportedInterfaceOrientations;
}

-(BOOL)shouldAutorotate {
    UIViewController *top = self.topViewController;
    return [top shouldAutorotate];
}

#pragma mark - CKRouterDelegate
- (CKNavigationController *)navigationControllerForRouter:(CKRouter *)router {
    return self;
}

- (void)router:(CKRouter *)router didNavigationBarHiddenChanged:(BOOL)navigationBarHidden animated:(BOOL)animated {
    if (self.navigationBarHidden != navigationBarHidden) {
        [self setNavigationBarHidden:navigationBarHidden animated:animated];
    }
}

- (void)router:(CKRouter *)router targetViewControllerDidAppear:(BOOL)animated {
    if (router.isTargetViewControllerDisappearing &&
        self.navigationBarHidden != router.navigationBarHidden) {
        CKAsyncMainQueue(^{
            [self setNavigationBarHidden:router.navigationBarHidden animated:NO];
        });
        [self setNavigationBarHidden:router.navigationBarHidden animated:NO];
    }
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( gestureRecognizer == self.interactivePopGestureRecognizer ) {
        if ( self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
        UIViewController *topView = [self topViewController];
        if (topView.router.disableInteractivePopGestureRecognizer) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.ckdelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.ckdelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    if (self.navigationBarHidden != viewController.router.navigationBarHidden) {
        [self setNavigationBarHidden:viewController.router.navigationBarHidden animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = !self.router.disableInteractivePopGestureRecognizer;
    }
    if ([self.ckdelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.ckdelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}


@end






