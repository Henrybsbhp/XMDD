//
//  CKNavigationController.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-15.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <objc/runtime.h>
#import "CKNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+Runtime.h"

typedef enum : NSUInteger
{
    DirectionNone,
    DirectionLeft,
    DirectionRight
}Direction;

static const CGFloat kAnimationDuration = 0.35f;
static const CGFloat kAnimationDelay = 0.0f;
static const CGFloat kVelocityRatio = 0.6f;
static const CGFloat kTriggerOffset = 80;

@interface CKNavigationItem ()

@property (nonatomic, weak) CKNavigationController *mNavCtrl;
@property (nonatomic, weak) UIViewController *mVCtrl;
@property (nonatomic, copy) void (^mAnimationComplection)(void);
@end
@implementation CKNavigationItem
- (id)init
{
    self = [super init];
    if (self)
    {
        _allowPanGesture = YES;
    }
    return self;
}

@end

@interface CKNavigationController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL mIsAnimating;
@property (nonatomic, assign) BOOL mIsPaning;
@property (nonatomic, weak) UIViewController *mVisibleVC;
//@property (nonatomic, strong) UIPanGestureRecognizer *mPanGesutre;
@property (nonatomic, strong) NSArray *removedVCs;
@property (nonatomic, assign) Direction mPanDirection;
@end

@implementation CKNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    UIViewController *rootViewController = [self.viewControllers safetyObjectAtIndex:0];
    [self _setupNextViewController:rootViewController withAnimationStyle:kCKNavAnimationNone];
    [self _safetyAddView:rootViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
}

- (void)resetViewControllers:(NSArray *)viewControllers
{
    
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [self init];
    if (self)
    {
        self.viewControllers = [NSMutableArray arrayWithObject:rootViewController];
    }
    return self;
}

#pragma mark - Getter
- (UIViewController *)rootViewController
{
    return [self.viewControllers safetyObjectAtIndex:0];
}

#pragma mark - Public
- (void)pushViewController:(UIViewController *)vc
{
    [self pushViewController:vc completion:nil];
}

- (void)pushViewController:(UIViewController *)vc completion:(void (^)(void))completion
{
    [self pushViewController:vc animationStyle:kCKNavAnimationParallaxHorizontal completion:completion];
}

- (void)pushViewController:(UIViewController *)vc animationStyle:(CKNavAnimationStyle)style
{
    [self pushViewController:vc animationStyle:style completion:nil];
}

- (void)pushViewController:(UIViewController *)vc
            animationStyle:(CKNavAnimationStyle)style
                completion:(void(^)(void))completion
{
    NSLog(@">>>>>>>>>>>>>>>>PushToVC:%@", vc);
    [self _setupNextViewController:vc withAnimationStyle:style];
    [self.viewControllers addObject:vc];
    vc.customNavItem.mAnimationComplection = completion;
    
//    UIViewController *prevVC = [self previousViewController];
    
    if (style == kCKNavAnimationNone)
    {
//        [prevVC viewWillDisappear:NO];
//        [vc viewWillAppear:NO];
        [self _pushWithAnimationNone];
    }
    else
    {
//        [prevVC viewWillDisappear:YES];
//        [vc viewWillAppear:YES];
    }
    
    if (style == kCKNavAnimationFlipHorizontal || style == kCKNavAnimationCrossDissolve)
    {
        [self _pushWithAnimationFlipHorizontalOrCrossDissolve];
    }
    else if (style == kCKNavAnimationCoverVertical || style == kCKNavAnimationCoverHorizontal)
    {
        [self _pushWithAnimationCoverVerticalOrCoverHorizontal];
    }
    else if (style == kCKNavAnimationParallaxHorizontal)
    {
        [self _pushWithAnimationParallaxHorizontal];
    }
}

- (void)popViewController
{
    [self popViewControllerWithCompletion:nil];
}

- (void)popViewControllerWithCompletion:(void (^)(void))completion
{
    [self popViewControllerToIndex:self.viewControllers.count-2 completion:completion];
}

- (void)popViewControllerToViewController:(UIViewController *)toVC
{
    [self popViewControllerToViewController:toVC completion:nil];
}

- (void)popViewControllerToViewController:(UIViewController *)toVC completion:(void (^)(void))completion
{
    NSInteger index = [self.viewControllers indexOfObject:toVC];
    [self popViewControllerToIndex:index completion:completion];
}

- (void)popViewControllerToIndex:(NSUInteger)index completion:(void(^)(void))completion
{
    CKNavAnimationStyle style = [self currentViewController].customNavItem.animationStyle;
    [self popViewControllerToIndex:index animationStyle:style completion:completion];
}

- (void)popViewControllerToIndex:(NSUInteger)index
                  animationStyle:(CKNavAnimationStyle)style
                      completion:(void(^)(void))completion
{
    if (index >= self.viewControllers.count-1)
    {
        return;
    }
    NSLog(@"<<<<<<<<<<<<<<<PopToVC:%@", [self.viewControllers safetyObjectAtIndex:index]);
    UIViewController *curVC = [self currentViewController];
    curVC.customNavItem.mAnimationComplection = completion;
    
    if (style == kCKNavAnimationNone)
    {
        [self _willPopToIndex:index animate:NO];
        [self _popWithAnimationNoneToIndex:index];
    }
    else
    {
        [self _willPopToIndex:index animate:YES];
    }
    if (style == kCKNavAnimationFlipHorizontal || style == kCKNavAnimationCrossDissolve)
    {
        [self _popWithAnimationFlipHorizontalOrCrossDissolveToIndex:index];
    }
    else if (style == kCKNavAnimationCoverVertical || style == kCKNavAnimationCoverHorizontal)
    {
        [self _popWithAnimationCoverVerticalOrCoverHorizontalToIndex:index];
    }
    else if (style == kCKNavAnimationParallaxHorizontal)
    {
        [self _popWithAnimationParallaxHorizontalToIndex:index];
    }
}

- (void)removeAllViewControllersExceptTopViewContrller
{
    NSInteger topIndex = self.viewControllers.count - 1;
    if (topIndex > 0)
    {
        [self removeViewControllerAtRange:NSMakeRange(0, topIndex)];
    }
}

- (void)removeViewController:(UIViewController *)vc
{
    NSUInteger index = [self.viewControllers indexOfObject:vc];
    [self removeViewControllerAtIndex:index];
}

- (void)removeViewControllerAtIndex:(NSInteger)index
{
    [self removeViewControllerAtRange:NSMakeRange(index, 1)];
}

- (void)removeViewControllerAtRange:(NSRange)range
{
    if (self.viewControllers.count-1 <= range.location)
    {
        return;
    }
    range.length = MIN(range.length, self.viewControllers.count-1 - range.location);
    NSArray *removed = [self.viewControllers safetyRemoveObjectsInRange:range];
    for (UIViewController *vc in removed)
    {
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [vc didMoveToParentViewController:nil];
    }
}

- (void)insertViewController:(UIViewController *)vc atIndex:(NSInteger)index
{
    [self _setupNextViewController:vc withAnimationStyle:kCKNavAnimationParallaxHorizontal];
    [self.viewControllers safetyInsertObject:vc atIndex:index];
}

- (UIViewController *)topViewController
{
    return [self.viewControllers lastObject];
}
- (UIViewController *)prevViewController
{
    return [self.viewControllers safetyObjectAtIndex:self.viewControllers.count -2];
}
#pragma mark - Utilities
- (void)_setupNextViewController:(UIViewController *)vc withAnimationStyle:(CKNavAnimationStyle)style
{
    [self _createNavItemForViewController:vc withAnimationStyle:style];
    [vc willMoveToParentViewController:self];
    
    vc.view.opaque = NO;
    vc.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    CGRect frame = self.view.bounds;
    frame.origin.x = style == kCKNavAnimationParallaxHorizontal ? frame.size.width : 0;
    vc.view.frame = frame;
    
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
}

- (void)_createNavItemForViewController:(UIViewController *)vc withAnimationStyle:(CKNavAnimationStyle)style
{
    CKNavigationItem *item = [[CKNavigationItem alloc] init];
    item.mNavCtrl = self;
    item.mVCtrl = vc;
    item.animationStyle = style;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(gestureRecognizerDidPan:)];
    pan.delegate = self;
    item.panGesture = pan;
    vc.customNavItem = item;
    [vc.view addGestureRecognizer:pan];
}

- (void)_safetyAddView:(UIView *)view
{
    if (!view.superview)
    {
        [self.view addSubview:view];
    }
}

- (void)_safetyRemoveVCsFromIndex:(NSUInteger)index
{
    self.removedVCs = [self.viewControllers safetyRemoveObjectsFromIndex:index];
    UIViewController *vc;
    for (NSUInteger i = 0; i < self.removedVCs.count-1; i++)
    {
        vc = self.removedVCs[i];
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [vc didMoveToParentViewController:nil];
    }
    
    vc = self.removedVCs.lastObject;
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    [vc didMoveToParentViewController:nil];
}

#pragma mark - PushAnimation
- (void)_pushWithAnimationNone
{
    UIViewController *prevVC = [self previousViewController];
    UIViewController *curVC = [self currentViewController];
    
    [self _safetyAddView:curVC.view];
    if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
    {
        [self updateStatusBarAppearanceIfNeeded];
    }

    [prevVC.view removeFromSuperview];
    [prevVC viewDidDisappear:NO];
    [curVC viewDidAppear:NO];
}

- (void)_pushWithAnimationFlipHorizontalOrCrossDissolve
{
    UIViewController *prevVC = [self previousViewController];
    UIViewController *curVC = [self currentViewController];
    CKNavAnimationStyle style = curVC.customNavItem.animationStyle;
    
    UIViewAnimationOptions option = (style == kCKNavAnimationCrossDissolve) ?
                                        UIViewAnimationOptionTransitionCrossDissolve :
                                        UIViewAnimationOptionTransitionFlipFromLeft;
    option |= UIViewAnimationCurveEaseInOut;
    NSTimeInterval duration = kCKNavAnimationCrossDissolve ? kAnimationDuration : 0.45;
    
    [UIView transitionWithView:self.view duration:duration options:option animations:^{
        
        [self _safetyAddView:curVC.view];
        if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
        {
            [self updateStatusBarAppearanceIfNeeded];
        }

    } completion:^(BOOL finished) {
        
        [prevVC.view removeFromSuperview];
        [prevVC viewDidDisappear:YES];
        [curVC viewDidAppear:YES];
        
        if (curVC.customNavItem.mAnimationComplection)
        {
            curVC.customNavItem.mAnimationComplection();
        }
    }];
}

- (void)_pushWithAnimationCoverVerticalOrCoverHorizontal
{
    UIViewController *curVC = [self currentViewController];
    UIViewController *prevVC = [self previousViewController];
    CGRect frame = self.view.bounds;
    if (curVC.customNavItem.animationStyle == kCKNavAnimationCoverHorizontal)
    {
        frame.origin.x = frame.size.width;
    }
    else
    {
        frame.origin.y = frame.size.height;
    }
    curVC.view.frame = frame;
    [self _safetyAddView:curVC.view];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        curVC.view.frame = self.view.bounds;
        
        if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
        {
            [self updateStatusBarAppearanceIfNeeded];
        }
    } completion:^(BOOL finished) {
        
        [prevVC.view removeFromSuperview];
        [prevVC viewDidDisappear:YES];
        [curVC viewDidAppear:YES];
        CKNavigationItem *item = [self currentViewController].customNavItem;
        if (item.mAnimationComplection)
        {
            item.mAnimationComplection();
        }
    }];
}

- (void)_pushWithAnimationParallaxHorizontal
{
    [self _pushWithAnimationParallaxHorizontalWithwithPrevViewXOrigin:0];
}

- (void)_pushWithAnimationParallaxHorizontalWithwithPrevViewXOrigin:(CGFloat)xOrigin
{
    UIViewController *curVC = [self currentViewController];
    UIViewController *prevVC = [self previousViewController];
    
    CGRect frame = self.view.bounds;
    frame.origin.x = xOrigin;
    prevVC.view.frame = frame;

    frame.origin.x = frame.size.width - fabs(floor(xOrigin/kVelocityRatio));
    curVC.view.frame = frame;
    [self _safetyAddView:curVC.view];
    [self showShadowForView:curVC.view];
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:kAnimationDelay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self->_mIsAnimating = YES;
                         curVC.view.userInteractionEnabled = NO;
                         prevVC.view.userInteractionEnabled = NO;
                         
                         CGRect frame = self.view.bounds;
                         curVC.view.frame = frame;
                         
                         frame.origin.x = -frame.size.width*kVelocityRatio;
                         prevVC.view.frame = frame;
                         
                         if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
                         {
                             [self updateStatusBarAppearanceIfNeeded];
                         }
                     } completion:^(BOOL finished) {
                         
                         curVC.view.userInteractionEnabled = YES;
                         prevVC.view.userInteractionEnabled = YES;
                         [prevVC.view removeFromSuperview];
                         [self hideShadowForView:curVC.view];
                         [prevVC viewDidDisappear:YES];
                         [curVC viewDidAppear:YES];
                         self->_mIsAnimating = NO;
                         
                         if (curVC.customNavItem.mAnimationComplection)
                         {
                             curVC.customNavItem.mAnimationComplection();
                         }
                     }];
}

#pragma mark - PopAnimation
- (void)_popWithAnimationNoneToIndex:(NSUInteger)index
{
    [self _safetyRemoveVCsFromIndex:index+1];
    [[self.removedVCs.lastObject view] removeFromSuperview];
    UIViewController *curVC = [self currentViewController];
    curVC.view.frame = self.view.bounds;
    [self _safetyAddView:curVC.view];

    if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
    {
        [self updateStatusBarAppearanceIfNeeded];
    }
    [self _didPopToIndex:index animate:NO];
}

- (void)_popWithAnimationFlipHorizontalOrCrossDissolveToIndex:(NSUInteger)index
{
    UIViewController *oldTopVC = [self currentViewController];
    CKNavAnimationStyle style = oldTopVC.customNavItem.animationStyle;
 
    [self _safetyRemoveVCsFromIndex:index+1];
    UIViewController *curTopVC = [self currentViewController];
    curTopVC.view.frame = self.view.bounds;
    
    UIViewAnimationOptions option = (style == kCKNavAnimationCrossDissolve) ?
    UIViewAnimationOptionTransitionCrossDissolve :
    UIViewAnimationOptionTransitionFlipFromRight;
    option |= UIViewAnimationCurveEaseInOut;
    NSTimeInterval duration = kCKNavAnimationCrossDissolve ? kAnimationDuration : 0.45;
    
    [UIView transitionWithView:self.view duration:duration options:option animations:^{
        
        [oldTopVC.view removeFromSuperview];
        [self _safetyAddView:curTopVC.view];
        
        if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
        {
            [self updateStatusBarAppearanceIfNeeded];
        }
        
    } completion:^(BOOL finished) {

        [self _didPopToIndex:index animate:YES];
        
        if (oldTopVC.customNavItem.mAnimationComplection)
        {
            oldTopVC.customNavItem.mAnimationComplection();
        }
        if (oldTopVC.customNavItem.didPopToPrevVCBlock)
        {
            oldTopVC.customNavItem.didPopToPrevVCBlock();
        }
    }];

}

- (void)_popWithAnimationCoverVerticalOrCoverHorizontalToIndex:(NSUInteger)index
{
    UIViewController *oldTopVC = [self currentViewController];
    [self _safetyRemoveVCsFromIndex:index+1];
    
    UIViewController *curTopVC = [self currentViewController];
    curTopVC.view.frame = self.view.bounds;
    [self.view insertSubview:curTopVC.view belowSubview:oldTopVC.view];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect frame = oldTopVC.view.frame;
        if (oldTopVC.customNavItem.animationStyle == kCKNavAnimationCoverHorizontal)
        {
            frame.origin.x = self.view.bounds.size.width;
        }
        else
        {
            frame.origin.y = self.view.bounds.size.height;
        }
        oldTopVC.view.frame = frame;
        
        if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
        {
            [self updateStatusBarAppearanceIfNeeded];
        }
    } completion:^(BOOL finished) {
       
        [oldTopVC.view removeFromSuperview];
        [self _didPopToIndex:index animate:YES];
        if (oldTopVC.customNavItem.mAnimationComplection)
        {
            oldTopVC.customNavItem.mAnimationComplection();
        }
    }];
}

- (void)_popWithAnimationParallaxHorizontalToIndex:(NSUInteger)index
{
    CGFloat xOrigin = -self.view.bounds.size.width*kVelocityRatio;
    return [self _popWithAnimationParallaxHorizontalToIndex:index withPrevViewXOrigin:xOrigin];
}

- (void)_popWithAnimationParallaxHorizontalToIndex:(NSUInteger)index withPrevViewXOrigin:(CGFloat)xOrigin
{
    UIViewController *curVC = [self currentViewController];
    [self _safetyRemoveVCsFromIndex:index+1];
    UIViewController *prevVC = [self currentViewController];
    
    
    CGRect frame = prevVC.view.frame;
    frame.origin.x = xOrigin;
    if (!prevVC.view.superview)
    {
        prevVC.view.frame = frame;
        [self.view insertSubview:prevVC.view belowSubview:curVC.view];
    }
    [self showShadowForView:curVC.view];
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:kAnimationDelay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self->_mIsAnimating = YES;
                         curVC.view.userInteractionEnabled = NO;
                         prevVC.view.userInteractionEnabled = NO;
                         
                         CGRect frame = self.view.bounds;
                         frame.origin.x = frame.size.width;
                         curVC.view.frame = frame;
                         
                         frame.origin.x = 0;
                         prevVC.view.frame = frame;
                         
                         if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
                         {
                             [self updateStatusBarAppearanceIfNeeded];
                         }
                     } completion:^(BOOL finished) {
                         
                         curVC.view.userInteractionEnabled = YES;
                         prevVC.view.userInteractionEnabled = YES;
                         [self hideShadowForView:curVC.view];
                         [curVC.view removeFromSuperview];
                         
                         self->_mIsAnimating = NO;
                         [self _didPopToIndex:index animate:YES];
                         
                         if (curVC.customNavItem.mAnimationComplection)
                         {
                             curVC.customNavItem.mAnimationComplection();
                         }
                     }];
    
}


- (void)_willPopToIndex:(NSUInteger)index animate:(BOOL)animate
{
    if (self.viewControllers.count <= index+1)
    {
        return;
    }

//    [self.viewControllers.lastObject viewWillDisappear:animate];
//    [[self.viewControllers objectAtIndex:index] viewWillAppear:animate];
}

- (void)_didPopToIndex:(NSUInteger)index animate:(BOOL)animate
{
//    [self.removedVCs.lastObject viewDidDisappear:animate];
    self.removedVCs = nil;
//    [[self.viewControllers safetyObjectAtIndex:index] viewDidAppear:animate];
}

#pragma mark - StatusBar
- (void)updateStatusBarAppearanceIfNeeded
{
    [self setNeedsStatusBarAppearanceUpdate];
//    NSLog(@"%@",[UIApplication sharedApplication].keyWindow);
//        UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
//    [rootVC setNeedsStatusBarAppearanceUpdate];

}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.viewControllers.lastObject preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.viewControllers.lastObject prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.viewControllers.lastObject preferredStatusBarUpdateAnimation];
}

#pragma mark - PanGestureRecognizer
- (void)addPanGestureForVC:(UIViewController *)vc
{
    [self.view addGestureRecognizer:vc.customNavItem.panGesture];
}

- (void)removePanGestureForVC:(UIViewController *)vc
{
    [self.view removeGestureRecognizer:vc.customNavItem.panGesture];
}

- (void)gestureRecognizerDidPan:(UIPanGestureRecognizer *)panGesture
{
    CGPoint currentPoint = [panGesture translationInView:self.view];
    CGFloat x = currentPoint.x;

    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        CGFloat vel = [panGesture velocityInView:self.view].x;
        //如果速度小于170则不做处理
        if (fabs(vel) < 170)
        {
            self.mIsPaning = NO;
            return;
        }

        self.mIsPaning = YES;
        self.mIsAnimating = YES;
        _mPanDirection = vel > 0 ? DirectionRight : DirectionNone;
        CKNavigationItem *item = [self currentViewController].customNavItem;
        NSLog(@"%@", item);
        if (_mPanDirection == DirectionNone && [self currentViewController].customNavItem.getNextVCBlockWhenPanLeft)
        {
            _mPanDirection = DirectionLeft;
            UIViewController *nextVC = [self currentViewController].customNavItem.getNextVCBlockWhenPanLeft();
            [self.viewControllers addObject:nextVC];
            [self _setupNextViewController:nextVC withAnimationStyle:kCKNavAnimationParallaxHorizontal];
//            [nextVC viewWillAppear:YES];
            [self.view addSubview:nextVC.view];
        }
        else if (self.viewControllers.count <= 1)
        {
            self.mIsPaning = NO;
            return;
        }
        [self currentViewController].view.userInteractionEnabled = NO;
        [self showShadowForView:[self currentViewController].view];
        [self previousViewController].view.userInteractionEnabled = NO;
    }
    else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded)
    {
        if (!self.mIsPaning)
        {
            return;
        }
        self.mIsPaning = NO;
        CGFloat prevX = [self previousViewController].view.frame.origin.x;
        if (_mPanDirection == DirectionLeft)
        {
            if (x < -kTriggerOffset)
            {
                [self _pushWithAnimationParallaxHorizontalWithwithPrevViewXOrigin:prevX];
            }
            else
            {
                [self _popWithAnimationParallaxHorizontalToIndex:self.viewControllers.count-2 withPrevViewXOrigin:prevX];
            }
        }
        else if (_mPanDirection == DirectionRight)
        {
            if (x > kTriggerOffset)
            {
                [self _popWithAnimationParallaxHorizontalToIndex:self.viewControllers.count-2 withPrevViewXOrigin:prevX];
            }
            else
            {
                [self _pushWithAnimationParallaxHorizontalWithwithPrevViewXOrigin:prevX];
            }
        }
        else
        {
            self.mIsAnimating = NO;
            [self currentViewController].view.userInteractionEnabled = YES;
            [self previousViewController].view.userInteractionEnabled = YES;
        }
    }
    else
    {
        if (!self.mIsPaning)
        {
            return;
        }
        UIViewController * vc = [self currentViewController];
        UIViewController *prevVC = [self previousViewController];
        if (!prevVC.view.superview)
        {
            [self.view insertSubview:prevVC.view belowSubview:vc.view];
        }
        if (_mPanDirection == DirectionLeft)
        {
            CGRect frame = vc.view.frame;
            frame.origin.x = MAX(0, self.view.frame.size.width + x);
            vc.view.frame = frame;
            
            frame = prevVC.view.frame;
            frame.origin.x = MIN(x*kVelocityRatio, 0);
            prevVC.view.frame = frame;
        }
        else if (_mPanDirection == DirectionRight)
        {
            CGFloat w = self.view.frame.size.width;
            
            CGRect frame = vc.view.frame;
            frame.origin.x = MAX(0, x);
            vc.view.frame = frame;
            
            frame = prevVC.view.frame;
            frame.origin.x = MAX(-w*kVelocityRatio, -(w-x)*kVelocityRatio);
            prevVC.view.frame = frame;
//            vc.view.transform = CGAffineTransformMakeTranslation(MAX(0, x), 0);
//            prevVC.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
//                                                               MAX(-w*kVelocityRatio, -(w-x)*kVelocityRatio), 0);
        }
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CKNavigationItem *item = [self currentViewController].customNavItem;
    return item.animationStyle == kCKNavAnimationParallaxHorizontal && item.allowPanGesture && !_mIsAnimating;
}

#pragma mark - Shadow
- (void)showShadowForView:(UIView *)view
{
    if (!view.customObject)
    {
        view.layer.masksToBounds = NO;
        UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, 5, view.frame.size.height)];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        UIImage *img = [[UIImage imageNamed:@"CKResource.bundle/vertical_shadow.png"]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 0, 0)];
        shadowView.image = img;
        [view addSubview:shadowView];
        view.customObject = shadowView;
    }
}

- (void)hideShadowForView:(UIView *)view
{
    UIImageView *shadowView = view.customObject;
    [shadowView removeFromSuperview];
    view.customObject = nil;
}

#pragma mark - NextViewController
- (void)setupNextViewController:(UIViewController *)viewController
{
    [self createNavItemForViewController:viewController];
    [viewController willMoveToParentViewController:self];
    viewController.view.opaque = NO;
    viewController.view.frame = self.view.bounds;
    viewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    viewController.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
    [self.view addSubview:viewController.view];

    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
}

- (void)createNavItemForViewController:(UIViewController *)vc
{
    CKNavigationItem *item = [[CKNavigationItem alloc] init];
    item.mNavCtrl = self;
    item.mVCtrl = vc;

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(gestureRecognizerDidPan:)];
    pan.delegate = self;
    item.panGesture = pan;
    vc.customNavItem = item;
    [vc.view addGestureRecognizer:pan];
}

#pragma mark - ChildViewController
- (UIViewController *)currentViewController
{
    return self.viewControllers.lastObject;
}

- (UIViewController *)previousViewController
{
    return [self.viewControllers safetyObjectAtIndex:(self.viewControllers.count - 2)];
}
@end

@implementation UIViewController (CKNavigationController)
@dynamic customNavCtrl;
@dynamic customNavItem;

static char g_customNavItemKey;

- (CKNavigationController *)customNavCtrl
{
    return [self customNavItem].mNavCtrl;
}

- (void)setCustomNavItem:(CKNavigationItem *)customNavItem
{
    objc_setAssociatedObject(self, &g_customNavItemKey, customNavItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKNavigationItem *)customNavItem
{
    UIViewController *curVC = self;
    CKNavigationItem *item;
    while (curVC && !(item = objc_getAssociatedObject(curVC, &g_customNavItemKey)))
    {
        curVC = curVC.parentViewController;
    }
    return item;
}

@end
