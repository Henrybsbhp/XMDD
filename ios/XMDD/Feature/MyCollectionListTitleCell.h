//
//  MyCollectionListTitleCell.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/23.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewCell.h"

@interface MyCollectionListTitleCell : HKTableViewCell
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *checkBox;
@property (nonatomic, strong) UIImageView *closedView;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@end
