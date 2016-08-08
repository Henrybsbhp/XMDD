//
//  HKCollectionViewCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKCollectionViewCell.h"

@interface HKCollectionViewCell () {
    NSMutableDictionary *_linesDict;
}
@end
@implementation HKCollectionViewCell

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


@end
