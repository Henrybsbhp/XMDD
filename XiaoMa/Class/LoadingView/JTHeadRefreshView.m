//
//  JTHeadRefreshView.m
//  JTReader
//
//  Created by jiangjunchen on 13-10-11.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//
#import "JTHeadRefreshView.h"

@implementation JTHeadRefreshView

- (id)init
{
    self = [super init];
    if (self)
    {
        self.upInset = 44;
        self.slimeMissWhenGoingBack = YES;
        self.slime.bodyColor = [UIColor darkGrayColor];
        self.slime.skinColor = [UIColor whiteColor];
        self.slime.lineWith = 1;
        self.slime.shadowBlur = 4;
        self.slime.shadowColor = [UIColor darkGrayColor];
    }
    return self;
}

- (void)setLightStyle:(BOOL)lightStyle
{
    self.activityIndicationView.color = lightStyle ? [UIColor lightGrayColor] : [UIColor whiteColor];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
