//
//  ShopDetailCommentTitleCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTRatingView.h"

@interface ShopDetailCommentTitleCell : UICollectionViewCell
@property (nonatomic, strong) JTRatingView *ratingView;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UIButton *commentButton;

@end
