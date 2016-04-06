//
//  GasReminderCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface GasReminderCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) RTLabel *richLabel;
- (CGFloat)cellHeight;

@end


