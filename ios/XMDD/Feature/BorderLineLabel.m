//
//  HKLabel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BorderLineLabel.h"
#import "UIView+Layer.h"

@implementation BorderLineLabel

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutBorderLineIfNeeded];
}

@end
