//
//  GasReminderCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasReminderCell.h"

@implementation GasReminderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _iconView.frame = CGRectMake(10, 0, 23, 23);
    _iconView.image = [UIImage imageNamed:@"gas_mark"];
    [self.contentView addSubview:_iconView];
    
    _richLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
    [_richLabel setParagraphReplacement:@""];
    [self.contentView addSubview:_richLabel];
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGFloat x = 10+23+8;
    CGRect lbFrame = CGRectMake(x, 5, frame.size.width - x - 8, 0);
    self.richLabel.frame = lbFrame;
    [super setFrame:frame];
}

- (CGFloat)cellHeight
{
    return MAX(45, ceil([_richLabel optimumSize].height + 10));
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
