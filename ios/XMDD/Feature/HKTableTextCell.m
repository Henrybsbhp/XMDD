//
//  HKTableTextCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableTextCell.h"

@implementation HKTableTextCell
- (void)awakeFromNib {
    [self __commonInit];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_titleLabel];
    _titleLabelInsets = UIEdgeInsetsMake(0, 14, 0, 14);
    [self makeConstraints];
}

- (void)makeConstraints {
    @weakify(self);
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.contentView).offset(self.titleLabelInsets.top);
        make.left.equalTo(self.contentView).offset(self.titleLabelInsets.left);
        make.right.equalTo(self.contentView).offset(-self.titleLabelInsets.right);
        make.bottom.equalTo(self.contentView).offset(-self.titleLabelInsets.bottom);
    }];
}

- (void)setTitleLabelInsets:(UIEdgeInsets)titleLabelInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_titleLabelInsets, titleLabelInsets)) {
        _titleLabelInsets = titleLabelInsets;
        [self makeConstraints];
    }
}

@end
