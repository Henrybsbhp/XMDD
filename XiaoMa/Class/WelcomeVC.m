//
//  WelcomeVC.m
//  XiaoMa
//
//  Created by fuqi on 16/4/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "WelcomeVC.h"
#import <POP.h>

#define PageNumber 4

@interface WelcomeVC ()<UIScrollViewDelegate>

@property (nonatomic,strong)UIScrollView * scrollView;

@property (nonatomic,strong)UIView * welcomeView1;
@property (nonatomic,strong)UIView * welcomeView2;
@property (nonatomic,strong)UIView * welcomeView3;
@property (nonatomic,strong)UIView * welcomeView4;


// 第四栏
@property (nonatomic)BOOL isFirstAppearForWelocome4;

@property (nonatomic,strong)UIButton * sureBtn;
@property (nonatomic,strong)UIView * bottomView4;
@property (nonatomic,strong)UIImageView *bottomTitleView4;

@property (nonatomic,strong)UIImageView * popView;
@property (nonatomic,strong)UIImageView * phoneView;
@property (nonatomic,strong)UIImageView * peopleView;
@property (nonatomic,strong)UIImageView * yellowRibbonView;
@property (nonatomic,strong)UIImageView * yellowSmallRibbonView;
@property (nonatomic,strong)UIImageView * blueRibbonView;

@end

@implementation WelcomeVC

- (void)dealloc
{
    DebugLog(@"WelcomeVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollView];
    
    [self setupWelcome1];
    [self setupWelcome2];
    [self setupWelcome3];
    [self setupWelcome4];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    DebugLog(@"scrollViewDidEndDecelerating");
    NSInteger originIndex = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
    if (originIndex == 3)
    {
        if (!self.isFirstAppearForWelocome4)
        {
            [self beginAnimation4Welcome4];
            self.isFirstAppearForWelocome4 = YES;
        }
    }
}


#pragma mark - Setup

- (void)setupScrollView
{
    NSArray * colorArray = @[@[@(91),@(187),@(255)],@[@(253),@(202),@(80)],@[@(206),@(119),@(251)],@[@(24),@(208),@(106)]];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    [[RACObserve(self.scrollView, contentOffset) distinctUntilChanged] subscribeNext:^(NSValue * value) {
        
        CGPoint point = [value CGPointValue];
        CGFloat offsetX = point.x;
        NSInteger originIndex = offsetX / CGRectGetWidth(self.view.frame);
        NSInteger aimsIndex = originIndex + 1;
        CGFloat percent = ((NSInteger)offsetX % (NSInteger)CGRectGetWidth(self.view.frame)) / CGRectGetWidth(self.view.frame);
        
        if (aimsIndex >= PageNumber || originIndex < 0)
            return ;
        
        CGFloat originColorR = [colorArray[originIndex][0] floatValue];
        CGFloat originColorG = [colorArray[originIndex][1] floatValue];
        CGFloat originColorB = [colorArray[originIndex][2] floatValue];
        
        CGFloat aimsColorR = [colorArray[aimsIndex][0] floatValue];
        CGFloat aimsColorG = [colorArray[aimsIndex][1] floatValue];
        CGFloat aimsColorB = [colorArray[aimsIndex][2] floatValue];
        
        UIColor * color = [self getGradualColor:percent aimsColorR:aimsColorR aimsColorG:aimsColorG aimsColorB:aimsColorB originColorR:originColorR originColorG:originColorG originColorB:originColorB];
        [self.scrollView setBackgroundColor:color];
        
        if (aimsIndex == 3 && percent > 0.5)
        {
            if (!self.isFirstAppearForWelocome4)
            {
                self.phoneView.alpha = (1 / 0.5) * (percent - 0.5);
            }
            else
            {
                self.phoneView.alpha = 1.0f;
            }
        }
    }];
}

#pragma mark - Setup Welcome View
- (void)setupWelcome1
{
    
}
- (void)setupWelcome2
{
    
}
- (void)setupWelcome3
{
    
}
- (void)setupWelcome4
{
    self.welcomeView4.frame = CGRectMake(CGRectGetWidth(self.view.frame) * 3, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self.scrollView addSubview:self.welcomeView4];
    
    [self.welcomeView4 addSubview:self.phoneView];
    
    [self.bottomView4 addSubview:self.sureBtn];
    [self.bottomView4 addSubview:self.bottomTitleView4];
    
    [self.welcomeView4 addSubview:self.peopleView];
    [self.welcomeView4 addSubview:self.popView];
    
    [self.welcomeView4 addSubview:self.yellowRibbonView];
    [self.welcomeView4 addSubview:self.yellowSmallRibbonView];
    [self.welcomeView4 addSubview:self.blueRibbonView];
    
    [self.welcomeView4 addSubview:self.bottomView4];
    
    
    @weakify(self)
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self)
        make.centerX.equalTo(self.welcomeView4);
        make.bottom.equalTo(self.bottomView4.mas_top);
        make.height.mas_equalTo(CGRectGetHeight(self.view.frame) * 722 / 1334);
        make.width.equalTo(self.phoneView.mas_height).multipliedBy(501 /722.0);
    }];
    
    [self.bottomView4 mas_makeConstraints:^(MASConstraintMaker *make) {
       
        @strongify(self)
        make.left.right.bottom.equalTo(self.welcomeView4);
        make.height.equalTo(self.welcomeView4).multipliedBy(423/1334.0);
    }];
    
    [self.bottomTitleView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self)
        make.left.right.top.equalTo(self.bottomView4);
        make.height.equalTo(self.bottomTitleView4.mas_width).multipliedBy(226/750.0);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self)
        make.centerX.equalTo(self.bottomView4);
        make.top.equalTo(self.bottomTitleView4.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(130, 40));
    }];
    
    [self.peopleView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self)
        make.centerX.equalTo(self.welcomeView4).offset(20);
        make.top.equalTo(self.bottomView4);
        make.height.mas_equalTo(CGRectGetHeight(self.view.frame) * 226 / 1334.0);
        make.width.equalTo(self.peopleView.mas_height).multipliedBy(527 / 226.0);
    }];
    
    [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.phoneView).multipliedBy(200/500.0);
        make.bottom.equalTo(self.phoneView).multipliedBy(175/722.0);
        make.size.mas_equalTo(CGSizeMake(0, 0));
    }];
    
    [self.yellowRibbonView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.phoneView).multipliedBy(100/125.0);
        make.centerY.equalTo(self.phoneView).multipliedBy(105/180.0);
        make.size.mas_equalTo(CGSizeMake(0, 0));
    }];
    
    [self.yellowSmallRibbonView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.phoneView).multipliedBy(100/125.0);
        make.centerY.equalTo(self.phoneView).multipliedBy(105/180.0);
        make.size.mas_equalTo(CGSizeMake(0, 0));
    }];
    
    [self.blueRibbonView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.phoneView).multipliedBy(100/125.0);
        make.centerY.equalTo(self.phoneView).multipliedBy(105/180.0);
        make.size.mas_equalTo(CGSizeMake(0, 0));
    }];
}


#pragma mark - Utilitly
- (void)sureAction
{
    
}


- (UIColor *)getGradualColor:(CGFloat)percent
                     aimsColorR:(CGFloat)aimsColorR aimsColorG:(CGFloat)aimsColorG aimsColorB:(CGFloat)aimsColorB
                   originColorR:(CGFloat)originColorR originColorG:(CGFloat)originColorG originColorB:(CGFloat)originColorB
{
    CGFloat r = (aimsColorR - originColorR) * percent + originColorR;
    CGFloat g = (aimsColorG - originColorG) * percent + originColorG;
    CGFloat b = (aimsColorB - originColorB) * percent + originColorB;
    
    UIColor *color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
    return color;
}

- (void)beginAnimation4Welcome4
{
    POPBasicAnimation *peoplePositionYAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    peoplePositionYAnimation.toValue = @(self.peopleView.center.y - CGRectGetHeight(self.view.frame) * 226 / 1334);
    peoplePositionYAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    [self.peopleView pop_addAnimation:peoplePositionYAnimation forKey:@"peoplePositionYAnimation"];
    
    POPSpringAnimation *yellowRibbonPositionYAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    yellowRibbonPositionYAnimation.toValue = @(self.yellowRibbonView.center.y + 120.0 * CGRectGetHeight(self.phoneView.frame) / 360);
    yellowRibbonPositionYAnimation.springSpeed = 12.0f;
    yellowRibbonPositionYAnimation.springBounciness = 10.0f;
    yellowRibbonPositionYAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    POPSpringAnimation *yellowRibbonPositionXAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    yellowRibbonPositionXAnimation.toValue = @(self.yellowRibbonView.center.x + 180.0 * CGRectGetWidth(self.phoneView.frame) / 250);
    yellowRibbonPositionXAnimation.springSpeed = 12.0f;
    yellowRibbonPositionXAnimation.springBounciness = 10.0f;
    yellowRibbonPositionXAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    POPBasicAnimation *yellowRibbonSizeAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerSize];
    yellowRibbonSizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(38, 41)];
    yellowRibbonSizeAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    [self.yellowRibbonView pop_addAnimation:yellowRibbonPositionYAnimation forKey:@"yellowRibbonPositionYAnimation"];
    [self.yellowRibbonView pop_addAnimation:yellowRibbonPositionXAnimation forKey:@"yellowRibbonPositionXAnimation"];
    [self.yellowRibbonView pop_addAnimation:yellowRibbonSizeAnimation forKey:@"yellowRibbonSizeAnimation"];
    
    POPSpringAnimation *yellowSmallRibbonPositionXAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    yellowSmallRibbonPositionXAnimation.toValue = @(self.yellowSmallRibbonView.center.x - 40 * CGRectGetWidth(self.phoneView.frame) / 250);
    yellowSmallRibbonPositionXAnimation.springSpeed = 12.0f;
    yellowSmallRibbonPositionXAnimation.springBounciness = 10.0f;
    yellowSmallRibbonPositionXAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    POPBasicAnimation *yellowSmallRibbonSizeAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerSize];
    yellowSmallRibbonSizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(23, 20)];
    yellowSmallRibbonSizeAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    [self.yellowSmallRibbonView pop_addAnimation:yellowSmallRibbonPositionXAnimation forKey:@"yellowSmallRibbonPositionXAnimation"];
    [self.yellowSmallRibbonView pop_addAnimation:yellowSmallRibbonSizeAnimation forKey:@"yellowSmallRibbonSizeAnimation"];
    
    POPSpringAnimation *blueRibbonPositionYAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    blueRibbonPositionYAnimation.toValue = @(self.yellowRibbonView.center.y + 200 * CGRectGetHeight(self.phoneView.frame) / 360);
    blueRibbonPositionYAnimation.springSpeed = 12.0f;
    blueRibbonPositionYAnimation.springBounciness = 10.0f;
    blueRibbonPositionYAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    POPSpringAnimation *blueRibbonPositionXAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    blueRibbonPositionXAnimation.toValue = @(self.yellowRibbonView.center.x - 100 * CGRectGetWidth(self.phoneView.frame) / 250);
    blueRibbonPositionXAnimation.springSpeed = 12.0f;
    blueRibbonPositionXAnimation.springBounciness = 10.0f;
    blueRibbonPositionXAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    POPBasicAnimation *blueRibbonSizeAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerSize];
    blueRibbonSizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(33, 40)];
    blueRibbonSizeAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    [self.blueRibbonView pop_addAnimation:blueRibbonPositionYAnimation forKey:@"blueRibbonPositionYAnimation"];
    [self.blueRibbonView pop_addAnimation:blueRibbonPositionXAnimation forKey:@"blueRibbonPositionXAnimation"];
    [self.blueRibbonView pop_addAnimation:blueRibbonSizeAnimation forKey:@"blueRibbonSizeAnimation"];
    
    POPSpringAnimation *popSizeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
    popSizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(100.0 * CGRectGetWidth(self.phoneView.frame) / 250, 96.0 * CGRectGetWidth(self.phoneView.frame) / 250)];
    popSizeAnimation.springSpeed = 12.0f;
    popSizeAnimation.springBounciness = 10.0f;
    popSizeAnimation.beginTime = CACurrentMediaTime() + 0.25f;
    
    [self.popView pop_addAnimation:popSizeAnimation forKey:@"popSizeAnimation"];
}


#pragma mark - Lazy
- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * PageNumber, CGRectGetHeight(self.view.frame));
        [_scrollView setBackgroundColor:HEXCOLOR(@"#5bbbff")];
    }
    return _scrollView;
}

#pragma mark - Lazy Welcome View
- (UIView *)welcomeView4
{
    if (!_welcomeView4)
    {
        _welcomeView4 = [[UIView alloc] init];
        _welcomeView4.backgroundColor = [UIColor clearColor];
    }
    return _welcomeView4;
}

#pragma mark - Lazy Welcome View4 - SubViews
- (UIButton *)sureBtn
{
    if (!_sureBtn)
    {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sureBtn setTitle:@"立即开启" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:kDefTintColor forState:UIControlStateNormal];
        _sureBtn.layer.borderColor = kDefTintColor.CGColor;
        _sureBtn.layer.borderWidth = 0.5f;
        _sureBtn.layer.cornerRadius = 18.0;
        _sureBtn.layer.masksToBounds = YES;
        _sureBtn.frame = CGRectMake((self.view.frame.size.width - 130) / 2, self.view.frame.size.height - 80, 130, 36);
        @weakify(self);
        [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            @strongify(self)
            [self sureAction];
        }];
    }
    return _sureBtn;
}

- (UIView *)bottomView4
{
    if (!_bottomView4)
    {
        _bottomView4 = [[UIView alloc] init];
        _bottomView4.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView4;
}

- (UIImageView *)bottomTitleView4
{
    if (!_bottomTitleView4)
    {
        _bottomTitleView4 = [[UIImageView alloc] init];
        _bottomTitleView4.image = [UIImage imageNamed:@"welcome4_bottom_title"];
    }
    return _bottomTitleView4;
}

- (UIImageView *)phoneView
{
    if (!_phoneView)
    {
        _phoneView = [[UIImageView alloc] init];
        _phoneView.image = [UIImage imageNamed:@"welcome4_phone"];
        _phoneView.alpha = 0.0f;
    }
    return _phoneView;
}

- (UIImageView *)peopleView
{
    if (!_peopleView)
    {
        _peopleView = [[UIImageView alloc] init];
        _peopleView.image = [UIImage imageNamed:@"welcome4_people"];
    }
    return _peopleView;
}

- (UIImageView *)yellowRibbonView
{
    if (!_yellowRibbonView)
    {
        _yellowRibbonView = [[UIImageView alloc] init];
        _yellowRibbonView.image = [UIImage imageNamed:@"yellow_ribbon"];
    }
    return _yellowRibbonView;
}

- (UIImageView *)yellowSmallRibbonView
{
    if (!_yellowSmallRibbonView)
    {
        _yellowSmallRibbonView = [[UIImageView alloc] init];
        _yellowSmallRibbonView.image = [UIImage imageNamed:@"yellow_small_ribbon"];
    }
    return _yellowSmallRibbonView;
}

- (UIImageView *)blueRibbonView
{
    if (!_blueRibbonView)
    {
        _blueRibbonView = [[UIImageView alloc] init];
        _blueRibbonView.image = [UIImage imageNamed:@"blue_ribbon"];
    }
    return _blueRibbonView;
}

- (UIImageView *)popView
{
    if (!_popView)
    {
        _popView = [[UIImageView alloc] init];
        _popView.image = [UIImage imageNamed:@"welcome4_pop"];
    }
    return _popView;
}


@end
