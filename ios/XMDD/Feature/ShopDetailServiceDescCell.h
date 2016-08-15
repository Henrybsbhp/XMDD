//
//  ShopDetailServiceDescCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDetailServiceDescCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *descLabel;

+ (CGFloat)cellHeightWithDesc:(NSString *)desc contentWidth:(CGFloat)width;

@end
