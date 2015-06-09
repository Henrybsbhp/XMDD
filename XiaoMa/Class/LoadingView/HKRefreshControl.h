//
//  HKRefreshView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKRefreshControl : UIControl
@property (nonatomic, assign, readonly) BOOL refreshing;

- (id)initWithScrollView:(UIScrollView *)scrollView;
- (void)beginRefreshing;
- (void)endRefreshing;

@end
