//
//  GasPickAmountCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasPickAmountCell.h"
#import <CKSegmentHelper.h>

@interface GasPickAmountCell ()
@property (nonatomic, strong) CKSegmentHelper *radioHelper;
@end
@implementation GasPickAmountCell
- (void)dealloc
{
    
}

- (void)awakeFromNib
{
    [self __commonInit];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __commonInit];
        self.frame = frame;
    }
    return self;
}

- (void)__commonInit {
    if (!_richLabel) {
        RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectZero];
        [label setParagraphReplacement:@""];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = kGrayTextColor;
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];
        _richLabel = label;
    }
    //创建选择框
    if (!self.radioHelper) {
        self.radioHelper = [[CKSegmentHelper alloc] init];
    }
}

- (GasStepper *)stepper
{
    if (!_stepper) {
        _stepper = [self.contentView viewWithTag:1003];
    }
    return _stepper;
}

- (CGFloat)cellHeight
{
    if (_richLabel.text) {
        return ceil(10 + [_richLabel optimumSize].height + 8 + 54);
    }
    return 10 + 54;
}

- (void)setFrame:(CGRect)frame
{
    CGRect lbFrame = self.richLabel.frame;
    lbFrame.origin = CGPointMake(10, 10+54);
    lbFrame.size.width = frame.size.width - 20;
    self.richLabel.frame = lbFrame;
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.richLabel.frame;
    frame.size.height = [self.richLabel optimumSize].height;
    self.richLabel.frame = frame;
}


@end
