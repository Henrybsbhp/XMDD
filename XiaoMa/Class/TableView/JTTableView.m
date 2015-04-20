//
//  JTTableView.m
//  JTReader
//
//  Created by jiangjunchen on 13-11-19.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//
#import "JTTableView.h"

@implementation JTTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self commInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commInit];
    }
    return self;
}

- (void)commInit
{
    //  上拉刷新视图
//    self.headRefreshView = [[JTHeadRefreshView alloc] init];
//    self.headRefreshView.delegate = self;
//    [self addSubview:self.headRefreshView];
//
////    //  上拉加载视图
//    self.bottomLoadingView = [[JTLoadingView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//    [self setTableFooterView:self.bottomLoadingView];
}

#pragma mark - Setter and getter
- (void)setShowHeadRefreshView:(BOOL)showHeadRefreshView
{
    _showHeadRefreshView = showHeadRefreshView;
    if (showHeadRefreshView)
    {
        if (!self.headRefreshView)
        {
            self.headRefreshView = [[JTHeadRefreshView alloc] init];
            self.headRefreshView.delegate = self;
            [self addSubview:self.headRefreshView];
        }
        self.headRefreshView.hidden = NO;
    }
    else
    {
        self.headRefreshView.hidden = YES;
    }
}

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

#pragma mark - SRRefreshDelegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    if ([self.delegate respondsToSelector:@selector(tableViewDidStartRefresh:)])
    {
        [self.delegate tableViewDidStartRefresh:self];
    }
}

@end
