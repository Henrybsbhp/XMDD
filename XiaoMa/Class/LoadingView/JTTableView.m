//
//  JTTableView.m
//  JTReader
//
//  Created by jiangjunchen on 13-11-19.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//
#import "JTTableView.h"

@implementation JTTableView

#pragma mark - Setter and getter
- (void)setShowBottomLoadingView:(BOOL)showBottomLoadingView
{
    _showBottomLoadingView = showBottomLoadingView;
    if (showBottomLoadingView)
    {
        if (!self.bottomLoadingView)
        {
            self.bottomLoadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        }
        [self setTableFooterView:self.bottomLoadingView];
    }
    else
    {
        [self setTableFooterView:nil];
    }
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
@end
