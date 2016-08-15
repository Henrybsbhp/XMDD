//
//  ShopListTitleCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewCell.h"
#import "JTRatingView.h"

@interface ShopListTitleCell : HKTableViewCell
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JTRatingView *ratingView;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *closedView;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *distanceLabel;

@end
