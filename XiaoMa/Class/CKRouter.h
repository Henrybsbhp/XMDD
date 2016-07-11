//
//  CKRouter.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKList.h"
#import "CKNavigationController.h"

extern NSString *const kCKRouterTitle;

@protocol CKRouterDelegate;

@interface CKRouter : NSObject<CKItemDelegate>

+ (instancetype)routerWithViewControllerName:(NSString *)vcName;
+ (instancetype)routerWithTargetViewController:(UIViewController *)targetVC;
+ (instancetype)routerWithStoryboard:(NSString *)sbname andViewControllerID:(NSString *)sbid;

@property (nonatomic, weak, readonly) UIViewController *targetViewController;
@property (nonatomic, assign, readonly) BOOL isTargetViewControllerAppearing;
@property (nonatomic, assign, readonly) BOOL isTargetViewControllerDisappearing;
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL disableInteractivePopGestureRecognizer;
@property (nonatomic, strong) CKDict *userInfo;
@property (nonatomic, weak) id<CKRouterDelegate> delegate;

- (CKNavigationController *)navigationController;
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;

@end

@protocol CKRouterDelegate <NSObject>

- (CKNavigationController *)navigationControllerForRouter:(CKRouter *)router;
- (void)router:(CKRouter *)router didNavigationBarHiddenChanged:(BOOL)navigationBarHidden animated:(BOOL)animated;
@optional
- (void)router:(CKRouter *)router targetViewControllerWillAppear:(BOOL)animated;
- (void)router:(CKRouter *)router targetViewControllerDidAppear:(BOOL)animated;
- (void)router:(CKRouter *)router targetViewControllerWillDisappear:(BOOL)animated;
- (void)router:(CKRouter *)router targetViewControllerDidDisappear:(BOOL)animated;

@end
