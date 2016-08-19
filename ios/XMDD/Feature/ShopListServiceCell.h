//
//  ShopListServiceCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewCell.h"

@interface ShopListServiceCell : HKTableViewCell
@property (nonatomic, strong) UILabel *serviceLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UITapGestureRecognizer *serviceLabelTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *priceLabelTapGesture;
@end
