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
    [self __commonInit];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __commonInit];
        self.frame = frame;
    }
    return self;
}

- (void)__commonInit
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLb.frame = CGRectMake(0, 0, 150, 20);
        _titleLb.text = @"油卡充值说明";
        _titleLb.font = [UIFont systemFontOfSize:13];
        _titleLb.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
        _titleLb.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLb];
    }
    
    if (!_richLabel) {
        _richLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
        [_richLabel setParagraphReplacement:@"\n"];
        [_richLabel setLinkAttributes:@{@"size":@"12"}];
        [_richLabel setSelectedLinkAttributes:@{@"size":@"12",
                                                @"color":@"#888888"}];
        [self.contentView addSubview:_richLabel];
    }
}

- (void)setFrame:(CGRect)frame
{
    CGFloat x = 10;
    CGRect lbFrame = CGRectMake(x, 32, frame.size.width - x * 2, 0);
    self.richLabel.frame = lbFrame;
    [super setFrame:frame];
}

- (CGFloat)cellHeight
{
    if (_richLabel.text) {
        return MAX(45, ceil([_richLabel optimumSize].height + 37));
    }
    return 45;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = _titleLb.frame;
    frame.origin.y = 10;
    frame.origin.x = 10;
    _titleLb.frame = frame;
    
    frame = _richLabel.frame;
    frame.size.height = [_richLabel optimumSize].height;
    frame.origin.y = 32;
    _richLabel.frame = frame;
}

@end
