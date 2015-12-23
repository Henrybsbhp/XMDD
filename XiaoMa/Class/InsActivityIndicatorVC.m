//
//  InsActivityIndicatorVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/16.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsActivityIndicatorVC.h"
#import <MZFormSheetController.h>

@interface InsActivityIndicatorVC ()
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *indicatorView;
@property (nonatomic, weak) MZFormSheetController *sheet;
@end

@implementation InsActivityIndicatorVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    @weakify(self);
    if (!self.backgroundView) {
        self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.backgroundView.image = [UIImage imageNamed:@"ins_ani_bg"];
        [self.view addSubview:self.backgroundView];

        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.size.mas_equalTo(CGSizeMake(183, 183));
            make.center.equalTo(self.view);
        }];
    }

    if (!self.indicatorView) {
        self.indicatorView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.indicatorView.image = [UIImage imageNamed:@"ins_ani_circle"];
        [self.view addSubview:self.indicatorView];
        
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.size.mas_equalTo(CGSizeMake(183, 183));
            make.center.equalTo(self.view);
        }];
    }
    [self.view bringSubviewToFront:self.indicatorView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInViewController:(UIViewController *)vc
{
    [vc addChildViewController:self];
    
    UIView *maskView = [[UIView alloc] initWithFrame:vc.view.bounds];
    maskView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    maskView.alpha = 0;
    [maskView addSubview:self.view];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 200));
        make.center.equalTo(maskView);
    }];
    
    [vc.view addSubview:maskView];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        maskView.alpha = 1;
    } completion:nil];

    [self startAnimating];
}

- (void)dismiss
{
    CKAfter(0.2, ^{
        [self stopAnimating];
        [self.view.superview removeFromSuperview];
        [self removeFromParentViewController];
    });
}

- (void)startAnimating
{
    [self stopAnimating];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.indicatorView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimating
{
    [self.indicatorView.layer removeAllAnimations];
}

@end
