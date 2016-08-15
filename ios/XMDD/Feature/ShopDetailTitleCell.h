//
//  ShopDetailTitleCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKCollectionViewCell.h"
#import "JTRatingView.h"

@interface ShopDetailTitleCell : HKCollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, assign) BOOL isTipHighlight;


@end
