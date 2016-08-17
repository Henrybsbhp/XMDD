//
//  ShopDetailServiceDescCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailServiceDescCell.h"
#import "NSString+RectSize.h"

@implementation ShopDetailServiceDescCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _descLabel.font = [UIFont systemFontOfSize:13];
    _descLabel.textColor = kOrangeColor;
    _descLabel.numberOfLines = 0;
    [self.contentView addSubview:_descLabel];

    @weakify(self);
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(14);
        make.right.equalTo(self.contentView).offset(-14);
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
}

+ (CGFloat)cellHeightWithDesc:(NSString *)desc contentWidth:(CGFloat)width {
    CGSize size = [desc labelSizeWithWidth:width font:[UIFont systemFontOfSize:13]];
    return ceil(size.height + 10);
}

@end
