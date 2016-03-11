//
//  ScencePageVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ScencePageVC.h"
#import "ScencePhotoVC.h"
#import "PhotoBrowserVC.h"
#import "HKProgressView.h"
@interface ScencePageVC ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (strong, nonatomic) IBOutlet UIView *pageView;
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (strong, nonatomic) IBOutlet HKProgressView *progressView;

@property (nonatomic,strong) UIPageViewController *pageVC;
@property (nonatomic,strong) NSArray *viewArr;

@end

@implementation ScencePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configPageVC];
    [self setupUI];
    [self configProgressView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPageViewControllerDelegate

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished && completed)
    {
        NSInteger index = [self.viewArr indexOfObject:pageViewController.viewControllers.firstObject] + 1;
        self.progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index)];
    }
}

#pragma mark UIPageViewControllerDataSource

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.viewArr indexOfObject:viewController];
    if (index == 0)
    {
        return nil;
    }
    else
    {
        return self.viewArr[index - 1];
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self.viewArr indexOfObject:viewController];
    if (index == self.viewArr.count - 1)
    {
        return nil;
    }
    else
    {
        return self.viewArr[index + 1];
    }
}


#pragma mark Init

-(void)configPageVC
{
    [self addChildViewController:self.pageVC];
    [self.pageView addSubview:self.pageVC.view];
    [self.pageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

-(void)configProgressView
{
    self.progressView.titleArray = @[@"现场接触",@"车辆损失",@"车辆信息",@"证件照"];
    self.progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    self.progressView.normalColor = [UIColor colorWithHex:@"#f7f7f8" alpha:1];
}

-(void)setupUI
{
    self.nextStepBtn.layer.cornerRadius = 5;
    self.nextStepBtn.layer.masksToBounds = YES;
}



#pragma mark Action

- (IBAction)nextStepAction:(id)sender {
    //    @叶志成 下一步操作
}


#pragma mark LazyLoad

-(UIPageViewController *)pageVC
{
    if (!_pageVC)
    {
        _pageVC = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        [_pageVC setViewControllers:@[self.viewArr.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        _pageVC.dataSource = self;
        _pageVC.delegate = self;
    }
    return _pageVC;
}

-(NSArray *)viewArr
{
    if (!_viewArr)
    {
        ScencePhotoVC *contactVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ScencePhotoVC"];
        contactVC.index = 0;
        ScencePhotoVC *carLoseVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ScencePhotoVC"];
        carLoseVC.index = 1;
        ScencePhotoVC *carInfoVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ScencePhotoVC"];
        carInfoVC.index = 2;
        ScencePhotoVC *licenceVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ScencePhotoVC"];
        licenceVC.index = 3;
        _viewArr = @[contactVC,carLoseVC,carInfoVC,licenceVC];
    }
    return _viewArr;
}

@end
