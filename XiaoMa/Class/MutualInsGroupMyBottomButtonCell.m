//
//  MutualInsGroupMyBottomButtonCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupMyBottomButtonCell.h"

@implementation MutualInsGroupMyBottomButtonCell

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
    self.actionButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.actionButton setTitleColor:kDefTintColor forState:UIControlStateNormal];
    [self.contentView addSubview:self.actionButton];
    
    [self addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsZero];
    
    [self makeDefaultConstraints];
}

- (void)makeDefaultConstraints {
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

@end
