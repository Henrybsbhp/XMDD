//
//  ShopDetailServiceSegmentCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKCollectionViewCell.h"

@interface ShopDetailServiceSegmentCell : HKCollectionViewCell
@property (nonatomic, strong, readonly) UISegmentedControl *segmentControl;

- (void)setupSegmentControlWithItems:(NSArray *)items;

@end
