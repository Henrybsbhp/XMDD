//
//  UIView+DefaultEmptyView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UIView+DefaultEmptyView.h"
#import <Masonry.h>

@implementation UIView (DefaultEmptyView)

- (void)showDefaultEmptyViewWithImageName:(NSString *)imgName centerOffset:(CGFloat)offset
{
    UIImageView *imgView = self.customInfo[@"$DefaultEmptyView"];
    if (!imgView) {
        imgView =  [[UIImageView alloc] initWithFrame:CGRectZero];
        self.customInfo[@"$DefaultEmptyView"] = imgView;
        [self addSubview:imgView];
    }
    imgView.image = [UIImage imageNamed:imgName];
    imgView.hidden = NO;
    [self bringSubviewToFront:imgView];
    @weakify(self);
    [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).offset(offset);
    }];
}

- (void)hideDefaultEmptyView
{
    UIImageView *imgView = self.customInfo[@"$DefaultEmptyView"];
    imgView.hidden = YES;
}

@end
