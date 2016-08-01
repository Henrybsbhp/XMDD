//
//  AnimationBoardView.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AnimationBoardView.h"

@interface AnimationBoardView ()
@property (nonatomic, strong) UIImageView *firstImgView;
@property (nonatomic, strong) UIImageView *secondImgView;
@property (nonatomic, strong) UIImageView *thirdImgView;
@property (nonatomic, strong) UIImageView *fourthImgView;
@end


@implementation AnimationBoardView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.firstImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -80, 105, 105)];
        self.firstImgView.image = [UIImage imageNamed:@"ani_bigcircle"];
        self.secondImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 110, 74, 47)];
        self.secondImgView.image = [UIImage imageNamed:@"ani_envelope"];
        self.thirdImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43, 48, 20, 20)];
        self.thirdImgView.image = [UIImage imageNamed:@"ani_smallcircle"];
        self.fourthImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43, 45, 25, 20)];
        self.fourthImgView.image = [UIImage imageNamed:@"ani_hook"];
    }
    return self;
}

-(void)successAnimation
{
    [self moveDown:self.firstImgView andAnimationDuration:0.8 andWait:YES andLength:80];
    [self moveUp:self.secondImgView andAnimationDuration:0.8 andWait:YES andLength:80];
    [self fadeIn:self.firstImgView andAnimationDuration:0.8 andWait:YES];
    [self fadeIn:self.secondImgView andAnimationDuration:0.8 andWait:YES];
    [self addSubview:self.firstImgView];
    [self addSubview:self.secondImgView];
}

-(void) moveUp: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait andLength:(float) length{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [UIView animateWithDuration:duration animations:^{
        view.center = CGPointMake(view.center.x, view.center.y-length);
        
    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
//    while (done == YES)
//        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

-(void) moveDown: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait andLength:(float) length{
    __block BOOL done = wait;
    [UIView animateWithDuration:duration animations:^{
        view.center = CGPointMake(view.center.x, view.center.y + length);
        
    } completion:^(BOOL finished) {
        done = NO;
    }];
}
-(void) fadeIn: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait{
    [view setAlpha:0.0];
    [UIView animateWithDuration:duration animations:^{
        [view setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self addSubview:self.thirdImgView];
        [self performSelector:@selector(showHook) withObject:nil afterDelay:0.1];
        
    }];
}
-(void) showHook
{
    [self addSubview:self.fourthImgView];
}
@end
