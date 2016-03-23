//
//  GasReminderCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKTableViewCell.h"
#import "RTLabel.h"

@interface GasReminderCell : HKTableViewCell

@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) RTLabel *richLabel;
- (CGFloat)cellHeight;

@end


