//
//  CKNavigationController.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKList.h"
@class CKRouter;

@interface UIViewController (CKNavigator)

@property (nonatomic, strong, readonly, nullable) CKRouter *router;

@end

@interface CKNavigationController : UINavigationController
@property(nullable, nonatomic, weak) id<UINavigationControllerDelegate> ckdelegate;

- (nonnull CKList *)routerList;
- (void)updateViewControllersByRouterList;
- (void)updateRouterListByViewControllers;
- (void)pushRouter:(nonnull CKRouter *)router animated:(BOOL)animated;
- (void)popToRouter:(nonnull CKRouter *)router animated:(BOOL)animated;
- (void)popToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end



