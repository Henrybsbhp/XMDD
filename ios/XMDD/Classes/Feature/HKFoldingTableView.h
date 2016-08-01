//
//  HKFoldingTableView.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKFoldingTableView : UITableView
@property (nonatomic, strong) UIView *foldingContainerView;
@property (nonatomic, assign, readonly) BOOL isFolded;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isDecelerating;

@property (nonatomic, assign) CGFloat maxFoldingHeight;
@property (nonatomic, assign) CGFloat minFoldingHeight;

- (void)setFolded:(BOOL)folded animated:(BOOL)animated;
- (void)didUpdateScrollContentOffset:(CGPoint)offset;
- (void)checkFoldedIfNeededWithAnimated:(BOOL)animated;

@end
