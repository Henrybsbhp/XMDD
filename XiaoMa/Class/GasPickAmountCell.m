//
//  GasPickAmountCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasPickAmountCell.h"

@implementation GasPickAmountCell
- (void)awakeFromNib
{
    if (!_richLabel) {
        RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectZero];
        [label setParagraphReplacement:@""];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = HEXCOLOR(@"#888888");
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];
        _richLabel = label;
    }
}

- (PKYStepper *)stepper
{
    if (!_stepper) {
        _stepper = (PKYStepper *)[self.contentView viewWithTag:1003];
        [_stepper setLabelTextColor:HEXCOLOR(@"#ff5a00")];
        _stepper.countLabel.font = [UIFont systemFontOfSize:20];
        [_stepper.incrementButton setTitle:nil forState:UIControlStateNormal];
        [_stepper.incrementButton setImage:[UIImage imageNamed:@"gas_add_red"] forState:UIControlStateNormal];
        [_stepper.decrementButton setTitle:nil forState:UIControlStateNormal];
        [_stepper.decrementButton setImage:[UIImage imageNamed:@"gas_minus_red"] forState:UIControlStateNormal];
        _stepper.cornerRadius = 0;
        _stepper.borderWidth = 0.5;
        _stepper.borderColor = HEXCOLOR(@"#ff5a00");
        _stepper.minimum = 100;
        _stepper.stepInterval = 100;
        _stepper.maximum = 2000;
        _stepper.value = 100;
    }
    return _stepper;
}

- (CGFloat)cellHeight
{
    if (_richLabel.text) {
        return ceil(10 + [_richLabel optimumSize].height + 8 + 44);
    }
    return 10 + 44;
}

- (void)setFrame:(CGRect)frame
{
    CGRect lbFrame = self.richLabel.frame;
    lbFrame.origin = CGPointMake(10, 10);
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
