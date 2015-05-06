//
//  JTTableViewCell.m
//  LiverApp
//
//  Created by jiangjunchen on 15/2/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "JTTableViewCell.h"
#import "UIView+Layer.h"
#import <CKKit.h>

@implementation JTTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    self.targetTableView = tableView;
    self.currentIndexPath = indexPath;
    if (self.targetTableView.separatorStyle!=UITableViewCellSeparatorStyleNone) {
        return;
    }
    //下边线
    NSInteger mask = CKViewBorderDirectionBottom;
    if (!self.currentIndexPath ||
        [self.targetTableView numberOfRowsInSection:self.currentIndexPath.section] > self.currentIndexPath.row+1) {
        [self.contentView setBorderLineInsets:self.customSeparatorInset forDirectionMask:CKViewBorderDirectionBottom];
    }
    else {
        [self.contentView setBorderLineInsets:UIEdgeInsetsZero forDirectionMask:CKViewBorderDirectionBottom];
    }
    //上边线
    if (self.currentIndexPath.row == 0 && self.hiddenTopSeparatorLine == NO) {
        mask |= CKViewBorderDirectionTop;
    }
//    mask |= self.currentIndexPath.row == 0 ? CKViewBorderDirectionTop : 0;
    [self.contentView setBorderLineInsets:UIEdgeInsetsMake(self.customSeparatorInset.top, 0, 0, 0)
                         forDirectionMask:CKViewBorderDirectionTop];
    [self.contentView showBorderLineWithDirectionMask:mask];
    [self.contentView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:mask];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView layoutBorderLineIfNeeded];
}

@end
