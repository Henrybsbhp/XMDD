//
//  JTLabel.m
//  EasyPay
//
//  Created by jiangjunchen on 14-10-15.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "JTLabel.h"
#import "CKKit.h"
@implementation JTLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.preferredMaxLayoutWidth = self.frame.size.width;
    }
}



@end
