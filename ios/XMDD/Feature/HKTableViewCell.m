//
//  HKTableViewCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKTableViewCell.h"

@interface HKTableViewCell () {
    NSMutableDictionary *_linesDict;
}
@end

@implementation HKTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    _customSeparatorInset = UIEdgeInsetsMake(0, 12, 0, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSMutableDictionary *)linesDict
{
    if (!_linesDict) {
        _linesDict = [NSMutableDictionary dictionary];
    }
    return _linesDict;
}

- (void)removeAllBorderLines
{
    for (CKLine *line in [[self linesDict] allValues]) {
        [line removeFromSuperview];
    }
    [[self linesDict] removeAllObjects];
}

- (void)removeBorderLineWithAlignment:(CKLineAlignment)alignment
{
    RACTuple *tuple = [[self linesDict] objectForKey:@(alignment)];
    if (tuple) {
        CKLine *line = tuple.first;
        [line removeFromSuperview];
        [[self linesDict] removeObjectForKey:@(alignment)];
    }
}

- (CKLine *)addOrUpdateBorderLineWithAlignment:(CKLineAlignment)alignment insets:(UIEdgeInsets)insets
{
    RACTuple *tuple = [[self linesDict] objectForKey:@(alignment)];
    CKLine *line = tuple.first;
    UIEdgeInsets oldInsets = [(NSValue *)tuple.second UIEdgeInsetsValue];
    if (line && UIEdgeInsetsEqualToEdgeInsets(insets, oldInsets)) {
        return line;
    }

    if (!line) {
        line = [[CKLine alloc] initWithFrame:CGRectZero];
        line.lineAlignment = alignment;
        line.linePointWidth = 1;
        line.lineColor = kDarkLineColor;
        [self.contentView addSubview:line];
    }
    UIView *contentV = self.contentView;
    if (alignment == CKLineAlignmentHorizontalTop) {
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentV).offset(insets.top);
            make.left.equalTo(contentV).offset(insets.left);
            make.right.equalTo(contentV).offset(-insets.right);
            make.height.mas_equalTo(1);
        }];
    }
    else if (alignment == CKLineAlignmentHorizontalBottom) {
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(contentV).offset(-insets.bottom);
            make.left.equalTo(contentV).offset(insets.left);
            make.right.equalTo(contentV).offset(-insets.right);
            make.height.mas_equalTo(1);
        }];
    }
    else if (alignment == CKLineAlignmentVerticalLeft) {
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(contentV).offset(insets.left);
            make.top.equalTo(contentV).offset(insets.top);
            make.bottom.equalTo(contentV).offset(-insets.bottom);
            make.width.mas_equalTo(1);
        }];
    }
    else if (alignment == CKLineAlignmentVerticalRight) {
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(contentV).offset(-insets.right);
            make.top.equalTo(contentV).offset(insets.top);
            make.bottom.equalTo(contentV).offset(-insets.bottom);
            make.width.mas_equalTo(1);
        }];
    }
    
    [[self linesDict] setObject:RACTuplePack(line, [NSValue valueWithUIEdgeInsets:insets]) forKey:@(alignment)];
    return line;
}

- (void)prepareCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    self.targetTableView = tableView;
    self.currentIndexPath = indexPath;
    if (tableView.separatorStyle!=UITableViewCellSeparatorStyleNone) {
        return;
    }
    //下边线
    if (!self.currentIndexPath ||
        [self.targetTableView numberOfRowsInSection:self.currentIndexPath.section] > self.currentIndexPath.row+1) {
        [self addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:self.customSeparatorInset];
    }
    else {
        [self addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    }
    
    //上边线
    if (self.currentIndexPath.row == 0) {
        [self addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsZero];
    }
    else {
        [self removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
    }
}

@end
