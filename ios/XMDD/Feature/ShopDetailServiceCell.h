//
//  ShopDetailServiceCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDetailServiceCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *radioButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *descLabel;

+ (CGFloat)cellHeightWithTitle:(NSString *)title desc:(NSString *)desc boundWidth:(CGFloat)width;

@end
