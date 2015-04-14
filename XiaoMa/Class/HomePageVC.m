//
//  HomePageVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HomePageVC.h"
#import <Masonry.h>
#import "XiaoMa.h"
#import "SYPaginator.h"

@interface HomePageVC ()<UIScrollViewDelegate, SYPaginatorViewDataSource, SYPaginatorViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *weatherView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) SYPaginatorView *adView;

@end

@implementation HomePageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupScrollView];
}

- (void)setupScrollView
{
    //天气视图
    [self.weatherView removeFromSuperview];
    [self.scrollView addSubview:self.weatherView];
    @weakify(self);
    [self.weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    UIView *container = [UIView new];
    [self.scrollView addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.weatherView.mas_bottom);
        make.left.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    //广告
    [self setupADViewInContainer:container];
    //洗车
    UIButton *btn1 = [self functionalButtonWithImageName:@"hp_washcar" action:@selector(actionWashCar:) inContainer:container];
    @weakify(btn1);
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn1);
        make.top.equalTo(self.adView.mas_bottom).offset(11);
        make.left.equalTo(container).offset(11);
        make.right.equalTo(container).offset(-11);
        make.height.equalTo(btn1.mas_width).multipliedBy(212.0/590);
    }];
    //保险
    UIButton *btn2 = [self functionalButtonWithImageName:@"hp_insurance" action:@selector(actionInsurance:) inContainer:container];
    @weakify(btn2);
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn2);
        make.left.equalTo(btn1.mas_left);
        make.top.equalTo(btn1.mas_bottom).offset(7);
        make.width.equalTo(btn1.mas_width).multipliedBy(0.5);
        make.height.equalTo(btn2.mas_width).multipliedBy(344.0f/346.0f);
    }];
    //专业救援
    UIButton *btn3 = [self functionalButtonWithImageName:@"hp_rescue" action:@selector(actionRescue:) inContainer:container];
    @weakify(btn3);
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn3);
        make.left.equalTo(btn2.mas_right).offset(7);
        make.right.equalTo(btn1.mas_right);
        make.top.equalTo(btn1.mas_bottom).offset(7);
        make.height.equalTo(btn3.mas_width).multipliedBy(165.0f/332.0f);
    }];
    //申请代办
    UIButton *btn4 = [self functionalButtonWithImageName:@"hp_commission" action:@selector(actionRescue:) inContainer:container];
    @weakify(btn4);
    [btn4 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(btn4);
        make.left.equalTo(btn3);
        make.right.equalTo(btn3);
        make.bottom.equalTo(btn2);
        make.height.equalTo(btn4.mas_width).multipliedBy(165.0f/332.0f);
    }];
   
    //底部
    [self setupBottomViewWithUpper:btn4];
    
    [container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btn4).offset(47+2);
    }];
}

- (void)setupADViewInContainer:(UIView *)container
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = width*360.0/1242.0;
    SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    adView.delegate = self;
    adView.dataSource = self;
    adView.pageGapWidth = 0;
    [container addSubview:adView];
    self.adView = adView;
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container);
        make.right.equalTo(container);
        make.top.equalTo(container);
        make.height.mas_equalTo(height);
    }];
    self.adView.currentPageIndex = 0;
}

- (void)setupBottomViewWithUpper:(UIView *)upper
{
    UIView *bottomView = [UIView new];
    UIImageView *imgView = [UIImageView new];
    imgView.image = [UIImage imageNamed:@"hp_bottom"];
    [bottomView addSubview:imgView];
    [self.scrollView addSubview:bottomView];
    self.bottomView = bottomView;
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.height.mas_equalTo(47);
        make.top.greaterThanOrEqualTo(upper.mas_bottom).offset(2).priorityMedium();
        make.bottom.greaterThanOrEqualTo(self.bgView).priorityHigh();
    }];
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView);
    }];
}
#pragma mark - Action
- (IBAction)actionCallCenter:(id)sender
{
    
}

- (IBAction)actionChooseCity:(id)sender
{
    
}

- (void)actionWashCar:(id)sender
{
    UIViewController *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionInsurance:(id)sender
{
    UIViewController *vc = [UIStoryboard vcWithId:@"InsuranceVC" inStoryboard:@"Insurance"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionRescue:(id)sender
{
    
}

- (void)actionCommission:(id)sender
{
    
}

#pragma mark - Utility
- (UIButton *)functionalButtonWithImageName:(NSString *)imgName action:(SEL)action inContainer:(UIView *)container
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor whiteColor];
    UIImage *img = [UIImage imageNamed:imgName];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor colorWithWhite:0.84 alpha:1.0].CGColor;
    btn.layer.borderWidth = 1.0;
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    [container addSubview:btn];
    return btn;
}

#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return 3;
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    SYPageView *pageView = [paginatorView dequeueReusablePageWithIdentifier:@"pageView"];
    if (!pageView) {
        pageView = [[SYPageView alloc] initWithReuseIdentifier:@"pageView"];
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:pageView.bounds];
        imgV.autoresizingMask = UIViewAutoresizingFlexibleAll;
        imgV.tag = 1001;
        [pageView addSubview:imgV];
    }
    UIImageView *imgV = (UIImageView *)[pageView viewWithTag:1001];
    imgV.image = [UIImage imageNamed:@"tmp_ad"];
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
}


@end
