//
//  JTAttributedLabel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "JTAttributedLabel.h"

@implementation JTAttributedLabel

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.preferredMaxLayoutWidth = self.frame.size.width;
    }
}


@end
