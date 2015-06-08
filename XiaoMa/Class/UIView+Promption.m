//
//  UIView+Promption.m
//  HappyTrain
//
//  Created by jt on 14-11-26.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "UIView+Promption.h"


@implementation UIView (Promption)

@dynamic promptionView;

static char sPromptionViewView;

- (PromptionView *)promptionView
{
    return objc_getAssociatedObject(self, &sPromptionViewView);
}

- (void)setPromptionView:(PromptionView *)promptionView
{
    objc_setAssociatedObject(self, &sPromptionViewView, promptionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)showErrorInfo:(NSString *)info andClickOp:(void (^)(void))completion
{
    if (!self.promptionView)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"PromptionView" owner:self options:nil];
        
        self.promptionView = nibArray[0];
        self.promptionView.frame = self.bounds;
        [self addSubview:self.promptionView];
    }
    
    [self.promptionView removeFromSuperview];
    [self addSubview:self.promptionView];
    self.promptionView.errorImage.hidden = NO;
    self.promptionView.infoLabel.hidden = NO;
    self.promptionView.infoLabel.preferredMaxLayoutWidth = 220;
    self.promptionView.clickBtn.hidden = NO;
    self.promptionView.dotAnimationView.hidden = YES;
    self.promptionView.infoLabel.text = info;
    [[[self.promptionView.clickBtn rac_signalForControlEvents:UIControlEventTouchUpInside] take:1] subscribeNext:^(id x) {
        
        if (completion)
        {
            completion();
        }
    }];
}

- (void)showLoadingInfo:(NSString *)info
{
    if (!self.promptionView)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"PromptionView" owner:self options:nil];
        
        self.promptionView = nibArray[0];
        self.promptionView.frame = self.bounds;
        [self addSubview:self.promptionView];
    }
    if (self.promptionView.superview != self)
    {
        [self addSubview:self.promptionView];
    }
    self.promptionView.errorImage.hidden = YES;
    self.promptionView.infoLabel.hidden = YES;
    self.promptionView.clickBtn.hidden = YES;
    self.promptionView.dotAnimationView.hidden = NO;
    self.promptionView.infoLabel.text = info;
    [self.promptionView.dotAnimationView startAnimating];
}

- (void)removePromptionView
{
    [self.promptionView removeFromSuperview];
}

- (void)refreshPromptionView
{
    if (self.promptionView.dotAnimationView.hidden == NO)
    {
        [self.promptionView.dotAnimationView startAnimating];
    }
}

@end
