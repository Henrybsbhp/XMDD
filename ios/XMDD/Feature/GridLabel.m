//
//  GradLabel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GridLabel.h"
#import "UIView+Layer.h"

@implementation GridLabel

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutBorderLineIfNeeded];
}

@end
