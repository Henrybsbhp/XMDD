//
//  CKNavigationController.h
//  JTReader
//
//  Created by jiangjunchen on 13-12-15.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKNavigationController;
@class CKNavigationItem;

typedef enum : NSInteger
{
    kCKNavAnimationNone = 0,
    kCKNavAnimationParallaxHorizontal,
    kCKNavAnimationCoverHorizontal,
    kCKNavAnimationCoverVertical,
    kCKNavAnimationFlipHorizontal,
    kCKNavAnimationCrossDissolve
}
CKNavAnimationStyle;

@interface CKNavigationItem : NSObject
///(Default is YES, 适用于animationStyle为kCKNavAnimationParallaxHorizontal的时候)
@property (nonatomic, assign) BOOL allowPanGesture;
///(当animationStyle 为kCKNavAnimationParallaxHorizontal时，该手势有效)
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
//当前视图被push时，使用的动画效果
@property (nonatomic, assign) CKNavAnimationStyle animationStyle;
///(Defalut is nil)
@property (nonatomic, copy) UIViewController *(^getNextVCBlockWhenPanLeft)(void);
///(defalut is YES)
@property (nonatomic, copy) void (^didPopToPrevVCBlock)(void);
@end

@interface CKNavigationController : UIViewController
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong, readonly) UIViewController *rootViewController;
- (id)initWithRootViewController:(UIViewController *)rootViewController;

///(Default animationStyle is kCKNavAnimationParallaxHorizontal)
- (void)pushViewController:(UIViewController *)vc;
///(Default animationStyle is kCKNavAnimationParallaxHorizontal)
- (void)pushViewController:(UIViewController *)vc completion:(void(^)(void))completion;
- (void)pushViewController:(UIViewController *)vc animationStyle:(CKNavAnimationStyle)style;
- (void)pushViewController:(UIViewController *)vc
            animationStyle:(CKNavAnimationStyle)style
                completion:(void(^)(void))completion;

- (void)popViewControllerToIndex:(NSUInteger)index
                  animationStyle:(CKNavAnimationStyle)style
                      completion:(void(^)(void))completion;
- (void)popViewControllerToIndex:(NSUInteger)index completion:(void(^)(void))completion;
- (void)popViewController;
- (void)popViewControllerWithCompletion:(void(^)(void))completion;
- (void)popViewControllerToViewController:(UIViewController *)toVC;
- (void)popViewControllerToViewController:(UIViewController *)toVC completion:(void(^)(void))completion;

- (void)removeAllViewControllersExceptTopViewContrller;
- (void)removeViewController:(UIViewController *)vc;
- (void)removeViewControllerAtIndex:(NSInteger)index;
- (void)removeViewControllerAtRange:(NSRange)range;

- (void)insertViewController:(UIViewController *)vc atIndex:(NSInteger)index;

- (UIViewController *)topViewController;
- (UIViewController *)prevViewController;
@end

@interface UIViewController (CKNavigationController)
@property (nonatomic, readonly) CKNavigationController *customNavCtrl;
@property (nonatomic, strong) CKNavigationItem *customNavItem;
@end

