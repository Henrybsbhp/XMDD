//
//  MutualInsGroupMyButtonCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupMyButtonCell.h"
#define kHorMargin     16

@implementation MutualInsGroupMyButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *bgimg = [[UIImage imageNamed:@"btn_bg_green"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.actionButton setBackgroundImage:bgimg forState:UIControlStateNormal];
    self.actionButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.actionButton];
    
    [self makeDefaultConstraints];
}

- (void)makeDefaultConstraints {
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leftMargin.mas_equalTo(kHorMargin);
        make.rightMargin.mas_equalTo(-kHorMargin);
        make.topMargin.mas_equalTo(0);
        make.size.mas_equalTo(50);
    }];
}

@end
