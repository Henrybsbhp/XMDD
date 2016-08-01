//
//  PopAnimation.m
//  XiaoMa
//
//  Created by RockyYe on 16/4/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#define LabelAnimationKey @"LabelAnimation"

#import "PopAnimation.h"
#import <pop/POP.h>

@implementation PopAnimation


+(void)animatedForLabel:(UILabel *)label fromValue:(CGFloat)fromValue toValue:(CGFloat) toValue andDuration:(NSTimeInterval)duration
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:LabelAnimationKey initializer:^(POPMutableAnimatableProperty *prop) {
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *string = nil;
            string = [NSString stringWithFormat:@"%.2f",values[0]];
            label.text = string;
            [label setAdjustsFontSizeToFitWidth:YES];
        };
    }];
    POPBasicAnimation *basicAnimation = [POPBasicAnimation easeInEaseOutAnimation];
    basicAnimation.property = prop;
    basicAnimation.toValue = @(toValue);
    basicAnimation.fromValue = @(fromValue);
    basicAnimation.duration = duration;
    [label pop_addAnimation:basicAnimation forKey:LabelAnimationKey];
}

@end
