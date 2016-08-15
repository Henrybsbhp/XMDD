//
//  ShopDetailCommentCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailCommentCell.h"

@implementation ShopDetailCommentCell

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
    
    _commentView = [[ShopCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"comment"];
    [self.contentView addSubview:_commentView];

    @weakify(self);
    [_commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.contentView);
    }];
}


@end
