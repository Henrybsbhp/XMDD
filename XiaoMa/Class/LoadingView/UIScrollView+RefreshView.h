//
//  UIScrollView+RefreshView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODRefreshControl.h"
#import "HKRefreshControl.h"

@interface UIScrollView (RefreshView)
@property (nonatomic, strong) HKRefreshControl *refreshView;
- (void)restartRefreshViewAnimatingWhenRefreshing;
- (BOOL)isRefreshViewExists;
@end
