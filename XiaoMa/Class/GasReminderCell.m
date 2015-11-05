//
//  GasReminderCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasReminderCell.h"

@implementation GasReminderCell

- (void)awakeFromNib {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.frame = CGRectMake(10, 0, 23, 23);
        _iconView.image = [UIImage imageNamed:@"gas_mark"];
        [self.contentView addSubview:_iconView];
    }
    
    if (!_richLabel) {
        _richLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
        [_richLabel setParagraphReplacement:@"\n"];
        [_richLabel setLinkAttributes:@{@"size":@"13"}];
        [_richLabel setSelectedLinkAttributes:@{@"size":@"13",
                                                @"color":@"#888888"}];
        [self.contentView addSubview:_richLabel];
    }
}

- (void)setFrame:(CGRect)frame
{
    CGFloat x = 10+23+8;
    CGRect lbFrame = CGRectMake(x, 8, frame.size.width - x - 8, 0);
    self.richLabel.frame = lbFrame;
    [super setFrame:frame];
}

- (CGFloat)cellHeight
{
    if (_richLabel.text) {
        return MAX(45, ceil([_richLabel optimumSize].height + 16));
    }
    return 45;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat centerY = self.frame.size.height/2.0;
    CGRect frame = _iconView.frame;
    frame.origin.y = floor(centerY-23.0/2);
    _iconView.frame = frame;
    
    frame = _richLabel.frame;
    frame.size.height = [_richLabel optimumSize].height;
    frame.origin.y = floor(centerY - frame.size.height/2.0);
    _richLabel.frame = frame;
}

@end
