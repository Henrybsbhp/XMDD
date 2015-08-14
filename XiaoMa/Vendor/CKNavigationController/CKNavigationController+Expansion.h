//
//  CKNavigationController+Expansion.h
//  JTReader
//
//  Created by jiangjunchen on 13-12-17.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "CKNavigationController.h"

@interface CKNavigationController (Expansion)
///(Default AnimationStyle is kCKNavAnimationParallaxHorizontal)
- (void)pushViewControllerWithTopBar:(UIViewController *)vc;
///(Default AnimationStyle is kCKNavAnimationParallaxHorizontal)
- (void)pushViewControllerWithTopBar:(UIViewController *)vc completion:(void(^)(void))completion;
- (void)pushViewControllerWithTopBar:(UIViewController *)vc animationStyle:(CKNavAnimationStyle)style;
- (void)pushViewControllerWithTopBar:(UIViewController *)vc
                      animationStyle:(CKNavAnimationStyle)style
                          completion:(void(^)(void))completion;
- (UIViewController *)viewControllerForClassName:(NSString *)className beforeIndex:(NSInteger)index;
- (UIViewController *)lasterVCForFilter:(BOOL(^)(UIViewController *vc))filter forCurrentIndex:(NSInteger)index;
@end

@interface UIViewController (NavigationBar)

- (IBAction)actionFlipBack:(id)sender;

@end
