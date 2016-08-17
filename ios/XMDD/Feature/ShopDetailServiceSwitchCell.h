//
//  ShopDetailServiceSwitchCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDetailServiceSwitchCell : UICollectionViewCell
@property (nonatomic, assign, readonly) BOOL isExpanded;

- (void)setExpand:(BOOL)expand title:(NSString *)title animated:(BOOL)animated;

@end
