//
//  GuideViewController.m
//  XiaoMa
//
//  Created by jt on 15/12/29.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "GuideViewController.h"
#import "MainTabBarVC.h"
#import <POP.h>

#define DeviceWidth gAppMgr.deviceInfo.screenSize.width
#define DeviceHeight gAppMgr.deviceInfo.screenSize.height
#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))

@interface GuideViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIImageView *iphoneView;
@property (nonatomic, strong) UIImageView *xiaomdaView1;
@property (nonatomic, strong) UIImageView *titleView1;
@property (nonatomic, strong) UIImageView *pageOneSubTilteView1;
@property (nonatomic, strong) UIImageView *pageOneSubTilteView2;


@property (nonatomic, strong) UIImageView *insuranceView;
@property (nonatomic, strong) UIImageView *xiaomdaView2;
@property (nonatomic, strong) UIImageView *titleView2;
@property (nonatomic, strong) UIImageView *pageTwoSubTilteView;

@property (nonatomic, strong) UIImageView *violationView;
@property (nonatomic, strong) UIImageView *violationView2;
@property (nonatomic, strong) UIImageView *xiaomdaView3;
@property (nonatomic, strong) UIImageView *titleView3;
@property (nonatomic, strong) UIImageView *pageThreeSubTilteView;

@property (nonatomic, strong) UIImageView *commissionAndRescureView;
@property (nonatomic, strong) UIImageView *commissionAndRescureView2;
@property (nonatomic, strong) UIImageView *xiaomdaView4;
@property (nonatomic, strong) UIImageView *titleView4;
@property (nonatomic, strong) UIImageView *pageFourSubTilteView;

@property (nonatomic, strong) UIImageView *valuationView;
@property (nonatomic, strong) UIImageView *valuationView2;
@property (nonatomic, strong) UIImageView *xiaomdaView5;
@property (nonatomic, strong) UIImageView *titleView5;
@property (nonatomic, strong) UIImageView *pageFiveSubTilteView;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIButton *switchToHomepageBtn;

@property (nonatomic)NSInteger currentPageIndex;


@end

@implementation GuideViewController

- (void)dealloc
{
    DebugLog(@"GuideViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(5 * CGRectGetWidth(self.view.frame),
                                             CGRectGetHeight(self.view.frame));
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    [self setupViews];
    [self setupAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self pageOneAppearAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfPages
{
    return 5;
}


#pragma mark - Setup
- (void)setupViews
{
    self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"26_guide_bg"]];
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    [self setupPageOne];
    [self setupPageTwo];
    [self setupPageThree];
    [self setupPageFour];
    [self setupPageFive];
    
    [self.view bringSubviewToFront:self.scrollView];
}

- (void)setupAnimations
{
    [self setupAnimationPageOne];
    [self setupAnimationPageTwo];
    [self setupAnimationPageThree];
    [self setupAnimationPageFour];
    [self setupAnimationPageFive];
}


#pragma mark - 位置
- (void)setupPageOne
{
    NSInteger currentPage = 0;
    CGPoint centerPoint = CGPointMake(DeviceWidth * (currentPage * 2 + 1) / 2, DeviceHeight / 2);
    
    NSString * iphoneViewName = [NSString stringWithFormat:@"26_guide_phone_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.iphoneView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iphoneViewName]];
    [self.scrollView addSubview:self.iphoneView];
    self.iphoneView.center = centerPoint;
    
    NSString * xiaomdaView1Name = [NSString stringWithFormat:@"26_guide_xiaoma1_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.xiaomdaView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:xiaomdaView1Name]];
    [self.scrollView addSubview:self.xiaomdaView1];
    self.xiaomdaView1.center = centerPoint;
    self.xiaomdaView1.alpha = 0.0f;
    
    NSString * titleView1Name = [NSString stringWithFormat:@"27_guide_title1_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.titleView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleView1Name]];
    [self.scrollView addSubview:self.titleView1];
    self.titleView1.center =  CGPointMake(- DeviceHeight / 2, DeviceHeight / 2);
    
    
    NSString * pageOneSubTilteView1Name = [NSString stringWithFormat:@"26_guide_subtitle_1_1_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.pageOneSubTilteView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pageOneSubTilteView1Name]];
    [self.scrollView addSubview:self.pageOneSubTilteView1];
    self.pageOneSubTilteView1.center =  centerPoint;

    
    NSString * pageOneSubTilteView2Name = [NSString stringWithFormat:@"26_guide_subtitle_1_2_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.pageOneSubTilteView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pageOneSubTilteView2Name]];
    [self.scrollView addSubview:self.pageOneSubTilteView2];
    self.pageOneSubTilteView2.center =  centerPoint;
}

- (void)setupPageTwo
{
    NSInteger currentPage = 1;
    CGPoint centerPoint = CGPointMake(DeviceWidth * (currentPage * 2 + 1) / 2, DeviceHeight / 2);
    
    NSString * insuranceViewName = [NSString stringWithFormat:@"26_guide_insurance_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.insuranceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:insuranceViewName]];
    [self.scrollView addSubview:self.insuranceView];
    self.insuranceView.center = centerPoint;
    
    NSString * xiaomdaView2Name = [NSString stringWithFormat:@"26_guide_xiaoma2_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.xiaomdaView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:xiaomdaView2Name]];
    [self.scrollView addSubview:self.xiaomdaView2];
    self.xiaomdaView2.center = centerPoint;
    
    NSString * titleView2Name = [NSString stringWithFormat:@"26_guide_title2_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.titleView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleView2Name]];
    [self.scrollView addSubview:self.titleView2];
    self.titleView2.center = centerPoint;
    
    NSString * pageTwoSubTilteView1Name = [NSString stringWithFormat:@"26_guide_subtitle_2_1_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.pageTwoSubTilteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pageTwoSubTilteView1Name]];
    [self.scrollView addSubview:self.pageTwoSubTilteView];
    self.pageTwoSubTilteView.center =  centerPoint;

}

- (void)setupPageThree
{
    NSInteger currentPage = 2;
    CGPoint centerPoint = CGPointMake(DeviceWidth * (currentPage * 2 + 1) / 2, DeviceHeight / 2);
    
    NSString * violationViewName = [NSString stringWithFormat:@"26_guide_violation_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.violationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:violationViewName]];
    [self.scrollView addSubview:self.violationView];
    self.violationView.center = centerPoint;
    
    NSString * violationViewName2 = [NSString stringWithFormat:@"26_guide_violation2_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.violationView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:violationViewName2]];
    [self.scrollView addSubview:self.violationView2];
//    self.violationView2.center = centerPoint;
    self.violationView2.frame = CGRectMake(DeviceWidth * 2 + 130 * 375 / DeviceWidth, 338 * 667 / DeviceHeight, 0, 0);
    
    NSString * xiaomdaView3Name = [NSString stringWithFormat:@"26_guide_xiaoma3_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.xiaomdaView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:xiaomdaView3Name]];
    [self.scrollView addSubview:self.xiaomdaView3];
    self.xiaomdaView3.center = centerPoint;
    
    NSString * titleView3Name = [NSString stringWithFormat:@"26_guide_title3_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.titleView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleView3Name]];
    [self.scrollView addSubview:self.titleView3];
    self.titleView3.center = centerPoint;
    
    NSString * pageThreeSubTilteViewName = [NSString stringWithFormat:@"26_guide_subtitle_3_1_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.pageThreeSubTilteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pageThreeSubTilteViewName]];
    [self.scrollView addSubview:self.pageThreeSubTilteView];
    self.pageThreeSubTilteView.center =  centerPoint;
}
- (void)setupPageFour
{
    NSInteger currentPage = 3;
    CGPoint centerPoint = CGPointMake(DeviceWidth * (currentPage * 2 + 1) / 2, DeviceHeight / 2);
    
    NSString * rescureViewName = [NSString stringWithFormat:@"26_guide_rescure_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.commissionAndRescureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:rescureViewName]];
    [self.scrollView addSubview:self.commissionAndRescureView];
    self.commissionAndRescureView.center = centerPoint;
    
    NSString * rescureViewName2 = [NSString stringWithFormat:@"26_guide_rescure2_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.commissionAndRescureView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:rescureViewName2]];
    [self.scrollView addSubview:self.commissionAndRescureView2];
//    self.commissionAndRescureView2.center = centerPoint;
    self.commissionAndRescureView2.frame = CGRectMake(DeviceWidth * 3 + 215 * 375 / DeviceWidth, 393 * 667 / DeviceHeight, 0, 0);
    
    NSString * xiaomdaView4Name = [NSString stringWithFormat:@"26_guide_xiaoma4_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.xiaomdaView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:xiaomdaView4Name]];
    [self.scrollView addSubview:self.xiaomdaView4];
    self.xiaomdaView4.center = centerPoint;
    
    NSString * titleView4Name = [NSString stringWithFormat:@"26_guide_title4_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.titleView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleView4Name]];
    [self.scrollView addSubview:self.titleView4];
    self.titleView4.center = centerPoint;
    
    NSString * pageFourSubTilteViewName = [NSString stringWithFormat:@"26_guide_subtitle_4_1_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.pageFourSubTilteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pageFourSubTilteViewName]];
    [self.scrollView addSubview:self.pageFourSubTilteView];
    self.pageFourSubTilteView.center =  centerPoint;
}


- (void)setupPageFive
{
    NSInteger currentPage = 4;
    CGPoint centerPoint = CGPointMake(DeviceWidth * (currentPage * 2 + 1) / 2, DeviceHeight / 2);
    
    NSString * valuationViewName = [NSString stringWithFormat:@"26_guide_valuation_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.valuationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:valuationViewName]];
    [self.scrollView addSubview:self.valuationView];
    self.valuationView.center = centerPoint;
    
    NSString * valuationView2Name = [NSString stringWithFormat:@"26_guide_valuation2_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.valuationView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:valuationView2Name]];
    [self.scrollView addSubview:self.valuationView2];
//    self.valuationView2.center = centerPoint;
   self.valuationView2.frame = CGRectMake(DeviceWidth * 4 + 130 * 375 / DeviceWidth, 338 * 667 / DeviceHeight, 0, 0);
    
    NSString * xiaomdaView5Name = [NSString stringWithFormat:@"26_guide_xiaoma5_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.xiaomdaView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:xiaomdaView5Name]];
    [self.scrollView addSubview:self.xiaomdaView5];
    self.xiaomdaView5.center = centerPoint;
    
    NSString * titleView5Name = [NSString stringWithFormat:@"26_guide_title5_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.titleView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleView5Name]];
    [self.scrollView addSubview:self.titleView5];
    self.titleView5.center = centerPoint;
    
    NSString * pageFiveSubTilteViewName = [NSString stringWithFormat:@"26_guide_subtitle_5_1_%ld_%ld",(long)DeviceWidth,(long)DeviceHeight];
    self.pageFiveSubTilteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pageFiveSubTilteViewName]];
    [self.scrollView addSubview:self.pageFiveSubTilteView];
    self.pageFiveSubTilteView.center =  centerPoint;
    
    self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"26_guide_arrow"]];
    [self.scrollView addSubview:self.arrowView];
    self.arrowView.center = CGPointMake(DeviceWidth * 5 - CGRectGetWidth(self.arrowView.frame) - 20, DeviceHeight / 2);
    
    self.switchToHomepageBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.switchToHomepageBtn.frame = CGRectMake(DeviceWidth * 4, 0 , DeviceWidth, DeviceHeight);
    [self.scrollView addSubview:self.switchToHomepageBtn];
    [[self.switchToHomepageBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        MainTabBarVC * mainTabVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTabBarVC"];
        [gAppDelegate resetRootViewController:mainTabVC];
        gAppMgr.clientInfo.lastClientVersion = gAppMgr.clientInfo.clientVersion;
    }];
}

#pragma mark - 动画
- (void)setupAnimationPageOne
{
    
}

- (void)setupAnimationPageTwo
{
    IFTTTAlphaAnimation * xiaomdaView2AlphaAnimation  = [[IFTTTAlphaAnimation alloc] initWithView:self.xiaomdaView2];
    [xiaomdaView2AlphaAnimation addKeyframeForTime:timeForPage(1.5) alpha:0.0f];
    [xiaomdaView2AlphaAnimation addKeyframeForTime:timeForPage(2) alpha:1.0f];
    [self.animator addAnimation:xiaomdaView2AlphaAnimation];
    
    IFTTTFrameAnimation * xiaomdaView2FrameAnimation = [[IFTTTFrameAnimation alloc] initWithView:self.xiaomdaView2];
    [xiaomdaView2FrameAnimation addKeyframeForTime:timeForPage(1.5) frame:CGRectOffset(self.xiaomdaView2.frame, DeviceWidth, DeviceHeight * 0.8)];
    [xiaomdaView2FrameAnimation addKeyframeForTime:timeForPage(2) frame:self.xiaomdaView2.frame];
    [self.animator addAnimation:xiaomdaView2FrameAnimation];
    
    IFTTTFrameAnimation * subTitleFrameAnimation = [[IFTTTFrameAnimation alloc] initWithView:self.pageTwoSubTilteView];
    
    [subTitleFrameAnimation addKeyframeForTime:timeForPage(1.5) frame:CGRectOffset(self.pageTwoSubTilteView.frame, 0, - DeviceHeight / 2)];
    [subTitleFrameAnimation addKeyframeForTime:timeForPage(2) frame:self.pageTwoSubTilteView.frame];
    
    [self.animator addAnimation:subTitleFrameAnimation];
}

- (void)setupAnimationPageThree
{
//    IFTTTHideAnimation * xiaomaView3HideAnimation1 = [[IFTTTHideAnimation alloc] initWithView:self.xiaomdaView3 hideAt:0];
//    IFTTTHideAnimation * xiaomaView3HideAnimation2 = [[IFTTTHideAnimation alloc] initWithView:self.xiaomdaView3 showAt:timeForPage(2.8)];
//    [self.animator addAnimation:xiaomaView3HideAnimation1];
//    [self.animator addAnimation:xiaomaView3HideAnimation2];
//    
//    IFTTTFrameAnimation * xiaomdaView3FrameAnimation = [[IFTTTFrameAnimation alloc] initWithView:self.xiaomdaView3];
//    [xiaomdaView3FrameAnimation addKeyframeForTime:timeForPage(2.8) frame:CGRectOffset(self.xiaomdaView3.frame, - DeviceWidth / 2,0)];
//    [xiaomdaView3FrameAnimation addKeyframeForTime:timeForPage(3) frame:self.xiaomdaView3.frame];
//    [self.animator addAnimation:xiaomdaView3FrameAnimation];
//    
//    IFTTTFrameAnimation * titleFrameAnimation = [[IFTTTFrameAnimation alloc] initWithView:self.titleView3];
//    
//    [titleFrameAnimation addKeyframeForTime:timeForPage(2.5) frame:CGRectOffset(self.titleView3.frame, 0, DeviceHeight / 2)];
//    [titleFrameAnimation addKeyframeForTime:timeForPage(3) frame:self.titleView3.frame];
//    
//    [self.animator addAnimation:titleFrameAnimation];
}


- (void)setupAnimationPageFour
{
;
}

- (void)setupAnimationPageFive
{
    
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    [self.animator animate:scrollView.contentOffset.x];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat w = CGRectGetWidth(self.view.frame);
    NSInteger index = scrollView.contentOffset.x / w;
    if (index == 0)
    {
        if (index != self.currentPageIndex)
        {
            [self pageOneAppearAnimation];
        }
        [self pageTwoRollback];
        [self pageThreeRollback];
        [self pageFourRollback];
        [self pageFiveRollback];
    }
    else if (index == 1)
    {
        [self pageOneRollback];
        [self pageThreeRollback];
        [self pageFourRollback];
        [self pageFiveRollback];
    }
    else if (index == 2)
    {
        if (index != self.currentPageIndex)
        {
            [self pageThreeAppearAnimation];
        }
        [self pageOneRollback];
        [self pageTwoRollback];
        [self pageFourRollback];
        [self pageFiveRollback];
    }
    else if (index == 3)
    {
        if (index != self.currentPageIndex)
        {
            [self pageFourAppearAnimation];
        }
        [self pageOneRollback];
        [self pageTwoRollback];
        [self pageThreeRollback];
        [self pageFiveRollback];
    }
    else if (index == 4)
    {
        if (index != self.currentPageIndex)
        {
            [self pageFiveAppearAnimation];
        }
        [self pageOneRollback];
        [self pageTwoRollback];
        [self pageThreeRollback];
        [self pageFourRollback];
    }
    self.currentPageIndex = index;
}


#pragma mark - Utilitly
- (void)pageOneAppearAnimation
{
    POPSpringAnimation * anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    
    CGFloat centerX = DeviceWidth / 2;
    CGFloat centerY = DeviceHeight / 2;
    
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerY)];
    anim.springBounciness = 8;
    anim.springSpeed = 6;
    //    anim.dynamicsTension = 100;
    anim.dynamicsMass = 2;
    [self.titleView1 pop_addAnimation:anim forKey:@"center"];
    

    
    
    self.xiaomdaView1.alpha = 0.0f;
    [UIView animateWithDuration:1 animations:^{
       
        self.xiaomdaView1.alpha = 1.0f;
    }];
    
    self.pageOneSubTilteView1.alpha = 0.0f;
    self.pageOneSubTilteView2.alpha = 0.0f;
    
    self.pageOneSubTilteView1.center =  CGPointMake(- DeviceHeight / 2, DeviceHeight / 2);
    self.pageOneSubTilteView2.center =  CGPointMake(- DeviceHeight / 2, DeviceHeight / 2);

    
    
    [UIView animateWithDuration:0.7 animations:^{
        
        self.pageOneSubTilteView1.alpha = 1.0f;
        self.pageOneSubTilteView1.center = CGPointMake(DeviceWidth / 2, DeviceHeight / 2);
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.pageOneSubTilteView2.alpha = 1.0f;
        
        self.pageOneSubTilteView2.center = CGPointMake(DeviceWidth / 2, DeviceHeight / 2);
    }];
}

- (void)pageThreeAppearAnimation
{
    CKAsyncMainQueue(^{
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.violationView2.frame = CGRectMake(DeviceWidth * 2, 0, DeviceWidth, DeviceHeight);
        }];
    });
    
}


- (void)pageFourAppearAnimation
{
    CKAsyncMainQueue(^{
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.commissionAndRescureView2.frame = CGRectMake(DeviceWidth * 3, 0, DeviceWidth, DeviceHeight);
        }];
    });
    
}

- (void)pageFiveAppearAnimation
{
    CKAsyncMainQueue(^{
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.valuationView2.frame = CGRectMake(DeviceWidth * 4, 0, DeviceWidth, DeviceHeight);
        }];
        
        CKAfter(0.5, ^{
            
            self.arrowView.alpha = 1.0f;
        });
    });
}


#pragma mark - 重置
- (void)pageOneRollback
{
    self.xiaomdaView1.alpha = 0.0f;
    
    self.pageOneSubTilteView1.alpha = 0.0f;
    self.pageOneSubTilteView2.alpha = 0.0f;
}

- (void)pageTwoRollback
{
    
}

- (void)pageThreeRollback
{
    self.violationView2.frame = CGRectMake(DeviceWidth * 2 + 130 * 375 / DeviceWidth, 338 * 667 / DeviceHeight, 0, 0);
}
- (void)pageFourRollback
{
    self.commissionAndRescureView2.frame = CGRectMake(DeviceWidth * 3 + 215 * 375 / DeviceWidth, 393 * 667 / DeviceHeight, 0, 0);
}
- (void)pageFiveRollback
{
    self.valuationView2.frame = self.valuationView2.frame = CGRectMake(DeviceWidth * 4 + 130 * 375 / DeviceWidth, 338 * 667 / DeviceHeight, 0, 0);
    self.arrowView.alpha = 0.0f;
}

@end
