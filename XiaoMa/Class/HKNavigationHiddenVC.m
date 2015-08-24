//
//  HKNavigationHiddenVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/24.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKNavigationHiddenVC.h"

@interface HKNavigationHiddenVC ()
@property (nonatomic, assign) BOOL isViewAppearing;
@end

@implementation HKNavigationHiddenVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isViewAppearing = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewAppearing = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //如果当前视图的导航条没有发生跳转，则不做处理
    if (![self.navigationController.topViewController isEqual:self]) {
        //如果当前视图的viewWillAppear和viewWillDisappear的间隔太短会导致navigationBar隐藏显示不正常
        //所以此时应该禁止navigationBar的动画,并在主线程中进行
        if (self.isViewAppearing) {
            CKAsyncMainQueue(^{
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            });
        }
        else {
            [self.navigationController setNavigationBarHidden:NO animated:animated];
        }
    }
}

@end
