//
//  ShopCommentCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewCell.h"
#import "JTRatingView.h"

@interface ShopCommentCell : HKTableViewCell
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) JTRatingView *ratingView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *serviceLabel;
@property (nonatomic, strong) UILabel *commentLabel;

+ (CGFloat)cellHeightWithComment:(NSString *)comment andBoundsWidth:(CGFloat)width;

@end
