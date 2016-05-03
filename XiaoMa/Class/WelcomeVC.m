//
//  WelcomeVC.m
//  XiaoMa
//
//  Created by fuqi on 16/4/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "WelcomeVC.h"
#import <POP.h>
#import "MainTabBarVC.h"

#define PageNumber 4
#define ScreenHeight        self.view.frame.size.height
#define TopViewHeight       self.view.frame.size.height * 911 / 1334.0
#define BottomViewHeight    self.view.frame.size.height * 423 / 1334.0
#define Scale               self.view.frame.size.width / 375.0


@interface WelcomeVC ()<UIScrollViewDelegate>

@property (nonatomic,strong)UIScrollView * scrollView;

@property (nonatomic,assign)NSInteger currentIndex;

@property (nonatomic,strong)UIView * welcomeView1;
@property (nonatomic,strong)UIView * welcomeView2;
@property (nonatomic,strong)UIView * welcomeView3;
@property (nonatomic,strong)UIView * welcomeView4;

// 第一页
@property (nonatomic)BOOL isFirstAppearForWelocome1;

@property (nonatomic, strong) UIImageView *rocketView;
@property (nonatomic, strong) UIImageView *cloudView;
@property (nonatomic, strong) UIImageView *smallGasView;
@property (nonatomic, strong) UIImageView *bigGasView;

// 第二页
@property (nonatomic)BOOL isFirstAppearForWelocome2;

@property (nonatomic, strong) UIImageView *people2View;
@property (nonatomic, strong) UIImageView *whiteStarView;
@property (nonatomic, strong) UIImageView *yellowStarView;

// 第三页
@property (nonatomic)BOOL isFirstAppearForWelocome3;

@property (nonatomic, strong) UIImageView *carView;
@property (nonatomic, strong) UIImageView *yellowBubbleView;
@property (nonatomic, strong) UIImageView *carGasView;

// 第四页
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
    
    //第一页的动画
    CKAfter(1, ^{
        [self beginAnimation1Welcome1];
    });
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5);
    if (self.currentIndex != index) {
        self.currentIndex = index;
        self.scrollView.userInteractionEnabled = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = YES;
    NSInteger originIndex = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
    if (originIndex == 1)
    {
        if (!self.isFirstAppearForWelocome2)
        {
            [self beginAnimation2Welcome2];
            self.isFirstAppearForWelocome2 = YES;
//            self.scrollView.scrollEnabled = NO;
        }
    }
    if (originIndex == 2)
    {
        if (!self.isFirstAppearForWelocome3)
        {
            [self beginAnimation3Welcome3];
            self.isFirstAppearForWelocome3 = YES;
//            self.scrollView.scrollEnabled = NO;
        }
    }
    if (originIndex == 3)
    {
        if (!self.isFirstAppearForWelocome4)
        {
            [self beginAnimation4Welcome4];
            self.isFirstAppearForWelocome4 = YES;
//            self.scrollView.scrollEnabled = NO;
        }
    }
}


#pragma mark - Setup

- (void)setupScrollView
{
    self.currentIndex = 0;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
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
    self.welcomeView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.scrollView addSubview:self.welcomeView1];
    
    CGFloat spacing = ScreenHeight > 480 ? 0 : 40;
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.frame = CGRectMake(ScreenWidth / 2 - 245 * Scale / 2,
                                   ScreenHeight * 200 / 1334.0 - spacing,
                                   245 * Scale,
                                   356 * Scale);
    bgImageView.image = [UIImage imageNamed:@"welcome1_bgimage"];
    [self.welcomeView1 addSubview:bgImageView];
    
    self.cloudView = [[UIImageView alloc] init];
    self.cloudView.frame = CGRectMake(ScreenWidth / 2 - 293 * Scale / 2,
                                  TopViewHeight + 10,
                                  293 * Scale,
                                  66 * Scale);
    self.cloudView.image = [UIImage imageNamed:@"welcome1_cloud"];
    [self.welcomeView1 addSubview:self.cloudView];
    
    self.rocketView = [[UIImageView alloc] init];
    self.rocketView.frame = CGRectMake(ScreenWidth / 2 - 72 * Scale / 2 - 30 * Scale,
                                   TopViewHeight + 5,
                                   72 * Scale,
                                   195 * Scale);
    self.rocketView.image = [UIImage imageNamed:@"welcome1_rocket"];
    [self.welcomeView1 addSubview:self.rocketView];
    
    self.smallGasView = [[UIImageView alloc] init];
    self.smallGasView.frame = CGRectMake(75 * Scale,
                                     (370 - spacing) * Scale,
                                     11.5, 16);
    self.smallGasView.image = [UIImage imageNamed:@"welcome1_gasleft"];
    self.smallGasView.alpha = 0;
    [self.welcomeView1 addSubview:self.smallGasView];
    
    self.bigGasView = [[UIImageView alloc] init];
    self.bigGasView.frame = CGRectMake(308 * Scale,
                                   TopViewHeight - 40 * Scale,
                                   28, 31.5);
    self.bigGasView.image = [UIImage imageNamed:@"welcome1_gasright"];
    self.bigGasView.alpha = 0;
    [self.welcomeView1 addSubview:self.bigGasView];
    
    //下半部分
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, TopViewHeight, self.view.frame.size.width, BottomViewHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.welcomeView1 addSubview:bottomView];
    
    UIImageView *wordsImgaeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375 * Scale, 113 * Scale)];
    wordsImgaeView.image = [UIImage imageNamed:@"welcome1_words"];
    [bottomView addSubview:wordsImgaeView];
    
    UIImageView *pageControlImgView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 75 / 2, bottomView.frame.size.height * 316 / 423, 75 * Scale, 15 * Scale)];
    pageControlImgView.image = [UIImage imageNamed:@"welcome1_pageid"];
    [bottomView addSubview:pageControlImgView];
}

- (void)setupWelcome2
{
    self.welcomeView2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.scrollView addSubview:self.welcomeView2];
    
    CGFloat spacing = ScreenHeight > 480 ? 0 : 40;
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.frame = CGRectMake(ScreenWidth / 2 - 270 * Scale / 2,
                                   ScreenHeight * 175 / 1334.0 - spacing,
                                   270 * Scale,
                                   366 * Scale);
    bgImageView.image = [UIImage imageNamed:@"welcome2_bgimage"];
    [self.welcomeView2 addSubview:bgImageView];
    
    self.people2View = [[UIImageView alloc] init];
    self.people2View.frame = CGRectMake(ScreenWidth,
                                   TopViewHeight - 195 * Scale,
                                   132 * Scale,
                                   195 * Scale);
    self.people2View.image = [UIImage imageNamed:@"welcome2_people"];
    [self.welcomeView2 addSubview:self.people2View];
    
    self.yellowStarView = [[UIImageView alloc] init];
    self.yellowStarView.frame = CGRectMake(bgImageView.frame.origin.x + 120 * Scale,
                                       (300 - spacing) * Scale,
                                       0, 0);
    self.yellowStarView.image = [UIImage imageNamed:@"welcome2_yellowstar"];
    [self.welcomeView2 addSubview:self.yellowStarView];
    
    self.whiteStarView = [[UIImageView alloc] init];
    self.whiteStarView.frame = CGRectMake(ScreenWidth - 55 * Scale,
                                      165 * Scale,
                                      0, 0);
    self.whiteStarView.image = [UIImage imageNamed:@"welcome2_whitestar"];
    [self.welcomeView2 addSubview:self.whiteStarView];
    
    
    //下半部分
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, TopViewHeight, self.view.frame.size.width, self.view.frame.size.height - TopViewHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.welcomeView2 addSubview:bottomView];
    
    UIImageView *wordsImgaeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50 *Scale, 375 * Scale, 69 * Scale)];
    wordsImgaeView.image = [UIImage imageNamed:@"welcome2_words"];
    [bottomView addSubview:wordsImgaeView];
    
    UIImageView *pageControlImgView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 75 / 2, bottomView.frame.size.height * 316 / 423, 75 * Scale, 15 * Scale)];
    pageControlImgView.image = [UIImage imageNamed:@"welcome2_pageid"];
    [bottomView addSubview:pageControlImgView];
}

- (void)setupWelcome3
{
    self.welcomeView3 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * 2, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.scrollView addSubview:self.welcomeView3];
    
    CGFloat spacing = ScreenHeight > 480 ? 0 : 40;
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.frame = CGRectMake(ScreenWidth / 2 - 275.5 * Scale / 2,
                                   ScreenHeight * 186 / 1334.0 - spacing,
                                   275.5 * Scale,
                                   361 * Scale);
    bgImageView.image = [UIImage imageNamed:@"welcome3_bgimage"];
    [self.welcomeView3 addSubview:bgImageView];
    
    self.carView = [[UIImageView alloc] init];
    self.carView.frame = CGRectMake(ScreenWidth,
                                    TopViewHeight - 71 * Scale,
                                    211.5 * Scale,
                                    71 * Scale);
    self.carView.image = [UIImage imageNamed:@"welcome3_car"];
    [self.welcomeView3 addSubview:self.carView];
    
    self.yellowBubbleView = [[UIImageView alloc] init];
    self.yellowBubbleView.frame = CGRectMake(84 * Scale,
                                             self.carView.frame.origin.y - 15 * Scale,
                                             0, 0);
    self.yellowBubbleView.image = [UIImage imageNamed:@"welcome3_bubble"];
    [self.welcomeView3 addSubview:self.yellowBubbleView];
    
    self.carGasView = [[UIImageView alloc] init];
    self.carGasView.frame = CGRectMake(ScreenWidth / 2 + 210 * Scale / 2,
                                       TopViewHeight - 45 * Scale,
                                       23, 27);
    self.carGasView.alpha = 0;
    self.carGasView.image = [UIImage imageNamed:@"welcome3_cargas"];
    [self.welcomeView3 addSubview:self.carGasView];
    
    
    //下半部分
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, TopViewHeight, self.view.frame.size.width, self.view.frame.size.height - TopViewHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.welcomeView3 addSubview:bottomView];
    
    UIImageView *wordsImgaeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50 *Scale, 375 * Scale, 69 * Scale)];
    wordsImgaeView.image = [UIImage imageNamed:@"welcome3_words"];
    [bottomView addSubview:wordsImgaeView];
    
    UIImageView *pageControlImgView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 75 / 2, bottomView.frame.size.height * 316 / 423, 75 * Scale, 15 * Scale)];
    pageControlImgView.image = [UIImage imageNamed:@"welcome3_pageid"];
    [bottomView addSubview:pageControlImgView];
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
        make.width.equalTo(self.phoneView.mas_height).multipliedBy(501 / 722.0);
    }];
    
    [self.bottomView4 mas_makeConstraints:^(MASConstraintMaker *make) {
       
        @strongify(self)
        make.left.right.bottom.equalTo(self.welcomeView4);
        make.height.equalTo(self.welcomeView4).multipliedBy(423 / 1334.0);
    }];
    
    [self.bottomTitleView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self)
        make.left.right.top.equalTo(self.bottomView4);
        make.height.equalTo(self.bottomTitleView4.mas_width).multipliedBy(226 / 750.0);
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

- (POPBasicAnimation *)setBasicAnimation:(NSString *)propertyName duration:(CFTimeInterval)duration toValue:(NSValue *)value beginTime:(CFTimeInterval)time
{
    POPBasicAnimation *basicAnimation = [POPBasicAnimation animationWithPropertyNamed:propertyName];
    basicAnimation.duration = duration;
    basicAnimation.toValue = value;
    basicAnimation.beginTime = time;
    return basicAnimation;
}

- (POPSpringAnimation *)setSpringAnimation:(NSString *)propertyName bounciness:(CFTimeInterval)bounciness toValue:(NSValue *)value beginTime:(CFTimeInterval)time
{
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:propertyName];
    springAnimation.springBounciness = bounciness;
    springAnimation.toValue = value;
    springAnimation.beginTime = time;
    return springAnimation;
}

- (void)beginAnimation1Welcome1
{
    NSValue *rocketEndPoint = [NSValue valueWithCGPoint:CGPointMake(self.rocketView.center.x - 68 * Scale, self.rocketView.center.y - 230 * Scale)];
    NSValue *cloudPosY = @(TopViewHeight - self.cloudView.frame.size.height / 2);
    NSValue *bigGasPosY = @(TopViewHeight - 60 * Scale);
    NSValue *smallGasPosY = ScreenHeight > 480 ? @(340 * Scale + self.smallGasView.frame.size.height / 2) : @(280 * Scale + self.smallGasView.frame.size.height / 2);
    
    POPBasicAnimation *rocketPositionAnimation = [self setBasicAnimation:kPOPLayerPosition duration:1.0f toValue:rocketEndPoint beginTime:CACurrentMediaTime() + 0.2];
    POPBasicAnimation *rocketRotationAnimation = [self setBasicAnimation:kPOPLayerRotation duration:1.0f toValue:@(-0.35) beginTime:CACurrentMediaTime()];
    
    [self.rocketView pop_addAnimation:rocketPositionAnimation forKey:@"rocketPosition"];
    [self.rocketView.layer pop_addAnimation:rocketRotationAnimation forKey:@"rocketRotation"];
    
    POPBasicAnimation *cloudAnimation = [self setBasicAnimation:kPOPLayerPositionY duration:0.8f toValue:cloudPosY beginTime:CACurrentMediaTime() + 0.3];
    [self.cloudView pop_addAnimation:cloudAnimation forKey:@"cloudPosition"];
    
    POPBasicAnimation *smallGasPosAnimation = [self setBasicAnimation:kPOPLayerPositionY duration:0.8f toValue:smallGasPosY beginTime:CACurrentMediaTime() + 0.6];
    
    POPBasicAnimation *smallGasOpacityAnimation = [self setBasicAnimation:kPOPLayerOpacity duration:0.8f toValue:@(1) beginTime:CACurrentMediaTime() + 0.6];
    
    [self.smallGasView pop_addAnimation:smallGasPosAnimation forKey:@"smallGasPosition"];
    [self.smallGasView.layer pop_addAnimation:smallGasOpacityAnimation forKey:@"smallGasOpacity"];
    
    POPBasicAnimation *bigGasPosAnimation = [self setBasicAnimation:kPOPLayerPositionY duration:0.8f toValue:bigGasPosY beginTime:CACurrentMediaTime() + 0.3];
    
    POPBasicAnimation *bigGasOpacityAnimation = [self setBasicAnimation:kPOPLayerOpacity duration:0.8f toValue:@(1) beginTime:CACurrentMediaTime() + 0.3];
    
    [self.bigGasView pop_addAnimation:bigGasPosAnimation forKey:@"bigGasPosition"];
    [self.bigGasView.layer pop_addAnimation:bigGasOpacityAnimation forKey:@"bigGasOpacity"];
    
    CKAfter(1.5, ^{
        self.scrollView.scrollEnabled = YES;
    });
}

- (void)beginAnimation2Welcome2
{
    POPBasicAnimation *peopleAnimation = [self setBasicAnimation:kPOPLayerPositionX duration:0.8f toValue:@(ScreenWidth / 2 + self.people2View.frame.size.width / 2) beginTime:CACurrentMediaTime()];
    [self.people2View pop_addAnimation:peopleAnimation forKey:@"peoplePosition"];
    
    POPSpringAnimation * yellowStarViewSizeAnimation = [self setSpringAnimation:kPOPLayerSize bounciness:20 toValue:[NSValue valueWithCGSize:CGSizeMake(22, 23)] beginTime:CACurrentMediaTime() + 0.3];
    [self.yellowStarView pop_addAnimation:yellowStarViewSizeAnimation forKey:@"yellowStarViewSize"];
    
    POPSpringAnimation * whiteStarViewSizeAnimation = [self setSpringAnimation:kPOPLayerSize bounciness:20 toValue:[NSValue valueWithCGSize:CGSizeMake(25, 30)] beginTime:CACurrentMediaTime() + 0.3];
    [self.whiteStarView pop_addAnimation:whiteStarViewSizeAnimation forKey:@"whiteStarViewSize"];
    
    CKAfter(1.5, ^{
        self.scrollView.scrollEnabled = YES;
    });
}

- (void)beginAnimation3Welcome3
{
    POPBasicAnimation *carAnimation = [self setBasicAnimation:kPOPLayerPositionX duration:0.8f toValue:@(ScreenWidth / 2) beginTime:CACurrentMediaTime()];
    [self.carView pop_addAnimation:carAnimation forKey:@"carPosition"];
    
    POPSpringAnimation * yellowBubbleViewSizeAnimation = [self setSpringAnimation:kPOPLayerSize bounciness:25 toValue:[NSValue valueWithCGSize:CGSizeMake(85, 99)] beginTime:CACurrentMediaTime() + 0.3];
    [self.yellowBubbleView pop_addAnimation:yellowBubbleViewSizeAnimation forKey:@"yellowBubbleViewSize"];
    
    POPBasicAnimation *carGasViewSizeAnimation = [self setBasicAnimation:kPOPLayerOpacity duration:0.5f toValue:@(1) beginTime:CACurrentMediaTime() + 0.6];
    [self.carGasView.layer pop_addAnimation:carGasViewSizeAnimation forKey:@"carGasViewOpacity"];
    
    CKAfter(1.5, ^{
        self.scrollView.scrollEnabled = YES;
    });
}

- (void)beginAnimation4Welcome4
{
    POPBasicAnimation *peoplePositionYAnimation = [self setBasicAnimation:kPOPLayerPositionY duration:0.5 toValue:@(self.peopleView.center.y - CGRectGetHeight(self.view.frame) * 226 / 1334) beginTime:CACurrentMediaTime() + 0.25f];
    [self.peopleView pop_addAnimation:peoplePositionYAnimation forKey:@"peoplePositionYAnimation"];
    
    POPSpringAnimation *yellowRibbonPositionYAnimation = [self setSpringAnimation:kPOPLayerPositionY bounciness:10.0f toValue:@(self.yellowRibbonView.center.y + 120.0 * CGRectGetHeight(self.phoneView.frame) / 360) beginTime:CACurrentMediaTime() + 0.25f];
    yellowRibbonPositionYAnimation.springSpeed = 12.0f;
    
    POPSpringAnimation *yellowRibbonPositionXAnimation = [self setSpringAnimation:kPOPLayerPositionX bounciness:10.0f toValue:@(self.yellowRibbonView.center.x + 180.0 * CGRectGetWidth(self.phoneView.frame) / 250) beginTime:CACurrentMediaTime() + 0.25f];
    yellowRibbonPositionXAnimation.springSpeed = 12.0f;
    
    POPBasicAnimation *yellowRibbonSizeAnimation = [self setBasicAnimation:kPOPLayerSize duration:0.5 toValue:[NSValue valueWithCGSize:CGSizeMake(38, 41)] beginTime:CACurrentMediaTime() + 0.25f];
    
    [self.yellowRibbonView pop_addAnimation:yellowRibbonPositionYAnimation forKey:@"yellowRibbonPositionYAnimation"];
    [self.yellowRibbonView pop_addAnimation:yellowRibbonPositionXAnimation forKey:@"yellowRibbonPositionXAnimation"];
    [self.yellowRibbonView pop_addAnimation:yellowRibbonSizeAnimation forKey:@"yellowRibbonSizeAnimation"];
    
    POPSpringAnimation *yellowSmallRibbonPositionXAnimation = [self setSpringAnimation:kPOPLayerPositionX bounciness:10.0f toValue:@(self.yellowSmallRibbonView.center.x - 40 * CGRectGetWidth(self.phoneView.frame) / 250) beginTime:CACurrentMediaTime() + 0.25f];
    yellowSmallRibbonPositionXAnimation.springSpeed = 12.0f;
    
    POPBasicAnimation *yellowSmallRibbonSizeAnimation = [self setBasicAnimation:kPOPLayerSize duration:0.5 toValue:[NSValue valueWithCGSize:CGSizeMake(23, 20)] beginTime:CACurrentMediaTime() + 0.25f];
    
    [self.yellowSmallRibbonView pop_addAnimation:yellowSmallRibbonPositionXAnimation forKey:@"yellowSmallRibbonPositionXAnimation"];
    [self.yellowSmallRibbonView pop_addAnimation:yellowSmallRibbonSizeAnimation forKey:@"yellowSmallRibbonSizeAnimation"];
    
    POPSpringAnimation *blueRibbonPositionYAnimation = [self setSpringAnimation:kPOPLayerPositionY bounciness:10.0f toValue:@(self.yellowRibbonView.center.y + 200 * CGRectGetHeight(self.phoneView.frame) / 360) beginTime:CACurrentMediaTime() + 0.25f];
    blueRibbonPositionYAnimation.springSpeed = 12.0f;
    
    POPSpringAnimation *blueRibbonPositionXAnimation = [self setSpringAnimation:kPOPLayerPositionX bounciness:10.0f toValue:@(self.yellowRibbonView.center.x - 100 * CGRectGetWidth(self.phoneView.frame) / 250) beginTime:CACurrentMediaTime() + 0.25f];
    blueRibbonPositionXAnimation.springSpeed = 12.0f;
    
    POPBasicAnimation *blueRibbonSizeAnimation = [self setBasicAnimation:kPOPLayerSize duration:0.5 toValue:[NSValue valueWithCGSize:CGSizeMake(33, 40)] beginTime:CACurrentMediaTime() + 0.25f];
    
    [self.blueRibbonView pop_addAnimation:blueRibbonPositionYAnimation forKey:@"blueRibbonPositionYAnimation"];
    [self.blueRibbonView pop_addAnimation:blueRibbonPositionXAnimation forKey:@"blueRibbonPositionXAnimation"];
    [self.blueRibbonView pop_addAnimation:blueRibbonSizeAnimation forKey:@"blueRibbonSizeAnimation"];
    
    POPSpringAnimation *popSizeAnimation = [self setSpringAnimation:kPOPLayerSize bounciness:10.0f toValue:[NSValue valueWithCGSize:CGSizeMake(100.0 * CGRectGetWidth(self.phoneView.frame) / 250, 96.0 * CGRectGetWidth(self.phoneView.frame) / 250)] beginTime: CACurrentMediaTime() + 0.25f];    popSizeAnimation.springSpeed = 12.0f;
    
    [self.popView pop_addAnimation:popSizeAnimation forKey:@"popSizeAnimation"];
    
    CKAfter(1.5, ^{
        self.scrollView.scrollEnabled = YES;
    });
}

- (void)sureAction
{
    MainTabBarVC * mainTabVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTabBarVC"];
    [gAppDelegate resetRootViewController:mainTabVC];
    gAppMgr.clientInfo.lastClientVersion = gAppMgr.clientInfo.clientVersion;
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
