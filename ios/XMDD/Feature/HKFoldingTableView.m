//
//  HKFoldingTableView.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKFoldingTableView.h"

@interface HKFoldingTableView ()
@property (nonatomic, assign) BOOL isAnimating;
@end

@implementation HKFoldingTableView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self __commintInitWithFrame:self.frame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __commintInitWithFrame:frame];
    }
    return self;
}

- (void)__commintInitWithFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(0, 0, frame.size.width, 0);
    _foldingContainerView = [[UIView alloc] initWithFrame:rect];
    _foldingContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _foldingContainerView.backgroundColor = [UIColor redColor];
    [self addSubview:_foldingContainerView];
}

#pragma mark - Public
- (void)setFolded:(BOOL)folded animated:(BOOL)animated
{
    [self setFolded:folded animated:animated reset:YES];
}

- (void)didUpdateScrollContentOffset:(CGPoint)offset
{
    NSLog(@"offset = %@", NSStringFromCGPoint(offset));
    CGFloat y = self.contentOffset.y;
    if (y > -self.minFoldingHeight && self.isFolded) {
        [self updateFoldingContainerViewFrameWithContentOffset:offset];
        return;
    }
    if (y < -self.maxFoldingHeight) {
        [self updateFoldingContainerViewFrameWithContentOffset:offset];
        return;
    }
    if ([self isFoldingContainerViewDidShifted]) {
        [self updateFoldingContainerViewFrameWithContentOffset:offset];
    }
    CGFloat distance = self.maxFoldingHeight - self.minFoldingHeight;
    if (y < -self.minFoldingHeight-distance/2 && self.isFolded) {
        [self setFolded:NO animated:YES];
    }
    else if (y > -self.minFoldingHeight-distance/2 && !self.isFolded) {
        [self setFolded:YES animated:YES];
    }
}

- (void)checkFoldedIfNeededWithAnimated:(BOOL)animated
{
    if (self.isDragging || self.isDecelerating || self.isAnimating) {
        return;
    }
    CGFloat y = self.contentOffset.y;
    CGFloat distance = self.maxFoldingHeight - self.minFoldingHeight;
    if (y < -self.minFoldingHeight-distance/2) {
        [self setFolded:NO animated:YES reset:NO];
        [self updateFoldingContainerViewFrameWithContentOffset:self.contentOffset];
    }
    else if (y > -self.minFoldingHeight-distance/2) {
        [self setFolded:YES animated:YES reset:NO];
    }
}

#pragma mark - Private
- (void)setFolded:(BOOL)folded animated:(BOOL)animated reset:(BOOL)reset
{
    _isFolded = folded;
   
    if (!reset && self.contentOffset.y >= -self.minFoldingHeight) {
        return;
    }

    CGFloat y = folded ? -self.minFoldingHeight : -self.maxFoldingHeight;
    if (!animated) {
        self.contentOffset = CGPointMake(0, y);
        [self updateContentInsetIfNeeded];
        return;
    }
    
    self.isAnimating = YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentOffset = CGPointMake(0, y);
    } completion:^(BOOL finished) {
        [self updateContentInsetIfNeeded];
        self.isAnimating = NO;
    }];
}

- (BOOL)isFoldingContainerViewDidShifted
{
    return self.foldingContainerView.frame.origin.y > -self.maxFoldingHeight;
}

- (void)updateContentInsetIfNeeded
{
    if (self.contentInset.top != self.maxFoldingHeight) {
        self.contentInset = UIEdgeInsetsMake(self.maxFoldingHeight, 0, 0, 0);
    }
}

- (void)updateFoldingContainerViewFrameWithContentOffset:(CGPoint)offset
{
    CGFloat y = 0;
    if (offset.y > -self.minFoldingHeight) {
        y = offset.y - (self.maxFoldingHeight - self.minFoldingHeight);
    }
    else if (offset.y < -self.maxFoldingHeight) {
        y = offset.y;
    }
    else {
        y = -self.maxFoldingHeight;
    }
    self.foldingContainerView.frame = CGRectMake(0, y, self.frame.size.width, self.maxFoldingHeight);
}

@end
