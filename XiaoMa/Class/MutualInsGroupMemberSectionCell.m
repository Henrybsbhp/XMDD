//
//  MutualInsGroupMemberSectionCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupMemberSectionCell.h"

@implementation MutualInsGroupMemberSectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectZero];
    titleL.font = [UIFont systemFontOfSize:14];
    titleL.textColor = kDarkTextColor;
    [self.contentView addSubview:titleL];
    self.titleLabel = titleL;
    
    UIButton *tipB = [[UIButton alloc] initWithFrame:CGRectZero];
    tipB.userInteractionEnabled = NO;
    [tipB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tipB.titleLabel.font = [UIFont systemFontOfSize:14];
    UIImage *tipBgImg = [[UIImage imageNamed:@"mins_tip_bg2"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
    [tipB setBackgroundImage:tipBgImg forState:UIControlStateNormal];
    tipB.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 15);
    [self.contentView addSubview:tipB];
    self.tipButton = tipB;
    
    @weakify(self);
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(tipB.mas_left).offset(-5);
    }];
    
    [tipB mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(0);
    }];
}



@end
