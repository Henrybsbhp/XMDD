//
//  MutualInsGroupNoticeItemCell.m
//  XMDD
//
//  Created by RockyYe on 2016/10/24.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupNoticeItemCell.h"

@implementation MutualInsGroupNoticeItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self __commonInit];
    }
    return self;
}

-(void)__commonInit
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = kGrayTextColor;
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.font = [UIFont systemFontOfSize:13];
    self.contentLabel.textColor = kDarkTextColor;
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.numberOfLines = 0;
    [self.contentView addSubview:self.contentLabel];

    [self makeDefaultConstraints];
}

- (void)makeDefaultConstraints
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(5);
        make.width.mas_equalTo(67);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).mas_equalTo(3);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(5);
    }];
}

@end
