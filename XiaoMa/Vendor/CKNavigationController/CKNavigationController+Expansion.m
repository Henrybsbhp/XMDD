//
//  CKNavigationController+Expansion.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-17.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "CKNavigationController+Expansion.h"
#import "JTNavigationController.h"

@implementation CKNavigationController (Expansion)

- (void)pushViewControllerWithTopBar:(UIViewController *)vc
{
    [self pushViewControllerWithTopBar:vc completion:nil];
}

- (void)pushViewControllerWithTopBar:(UIViewController *)vc completion:(void (^)(void))completion
{
    [self pushViewControllerWithTopBar:vc animationStyle:kCKNavAnimationParallaxHorizontal completion:completion];
}

- (void)pushViewControllerWithTopBar:(UIViewController *)vc animationStyle:(CKNavAnimationStyle)style
{
    [self pushViewControllerWithTopBar:vc animationStyle:style completion:nil];
}

- (void)pushViewControllerWithTopBar:(UIViewController *)vc
                      animationStyle:(CKNavAnimationStyle)style
                          completion:(void (^)(void))completion
{
    JTNavigationController *nav = [[JTNavigationController alloc] initWithRootViewController:vc];
    [self pushViewController:nav animationStyle:style completion:completion];
    UIBarButtonItem *backItem = [UIBarButtonItem backBarButtonItemWithTarget:vc
                                                                      action:@selector(actionFlipBack:)];
    [vc.navigationItem setLeftBarButtonItem:backItem];
}

- (UIViewController *)viewControllerForClassName:(NSString *)className beforeIndex:(NSInteger)index
{
    return [self lasterVCForFilter:^BOOL(UIViewController *vc) {
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [[(UINavigationController *)vc viewControllers] safetyObjectAtIndex:0];
            if ([className equalByCaseInsensitive:NSStringFromClass([vc class])]) {
                return YES;
            }
        }
        return NO;
    } forCurrentIndex:index];
}

- (UIViewController *)lasterVCForFilter:(BOOL(^)(UIViewController *vc))filter forCurrentIndex:(NSInteger)index
{
    UIViewController *vc = [self.viewControllers safetyObjectAtIndex:index];
    if (!vc) {
        return nil;
    }
    if (filter(vc)) {
        return vc;
    }
    return [self lasterVCForFilter:filter forCurrentIndex:index-1];
}
@end

@implementation UIViewController (NavigationBar)

- (IBAction)actionFlipBack:(id)sender
{
    [self.customNavCtrl popViewController];
}

@end
