//
//  CKRouter.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKRouter.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>


@interface CKRouter ()
@property (nonatomic, strong) id itemKey;
@end
@implementation CKRouter

+ (instancetype)routerWithTargetViewController:(UIViewController *)targetVC {
    CKRouter *router = [[CKRouter alloc] init];
    router->_targetViewController = targetVC;
    [router setKey:NSStringFromClass(targetVC.class)];
    [router observeTargetVC];
    return router;
}

#pragma mark - Key
- (id<NSCopying>)key {
    return _itemKey;
}
- (instancetype)setKey:(id<NSCopying>)key {
    _itemKey = key;
    return self;
}

#pragma mark -
- (void)observeTargetVC {
    @weakify(self);
    [[self.targetViewController rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(RACTuple *args) {
        @strongify(self);
        self->_isTargetViewControllerAppearing = YES;
        if ([self.delegate respondsToSelector:@selector(router:targetViewControllerWillAppear:)]) {
            [self.delegate router:self targetViewControllerWillAppear:[args.first boolValue]];
        }
    }];
    
    [[self.targetViewController rac_signalForSelector:@selector(viewDidAppear:)] subscribeNext:^(RACTuple *args) {
        @strongify(self);
        self->_isTargetViewControllerAppearing = NO;
        if ([self.delegate respondsToSelector:@selector(router:targetViewControllerDidAppear:)]) {
            [self.delegate router:self targetViewControllerDidAppear:[args.first boolValue]];
        }
    }];
    
    [[self.targetViewController rac_signalForSelector:@selector(viewWillDisappear:)] subscribeNext:^(RACTuple *args) {
        @strongify(self);
        self->_isTargetViewControllerDisappearing = YES;
        if ([self.delegate respondsToSelector:@selector(router:targetViewControllerWillDisappear:)]) {
            [self.delegate router:self targetViewControllerWillDisappear:[args.first boolValue]];
        }
    }];
    
    [[self.targetViewController rac_signalForSelector:@selector(viewDidDisappear:)] subscribeNext:^(RACTuple *args) {
        @strongify(self);
        self->_isTargetViewControllerDisappearing = NO;
        if ([self.delegate respondsToSelector:@selector(router:targetViewControllerDidDisappear:)]) {
            [self.delegate router:self targetViewControllerDidDisappear:[args.first boolValue]];
        }
    }];
}

- (CKNavigationController *)navigationController {
    if (self.delegate) {
        return [self.delegate navigationControllerForRouter:self];
    }
    return (CKNavigationController *)self.targetViewController.navigationController;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    _navigationBarHidden = navigationBarHidden;
    if (self.delegate) {
        [self.delegate router:self didNavigationBarHiddenChanged:navigationBarHidden animated:YES];
    }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated {
    _navigationBarHidden = navigationBarHidden;
    if (self.delegate) {
        [self.delegate router:self didNavigationBarHiddenChanged:navigationBarHidden animated:animated];
    }
}

@end