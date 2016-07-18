//
//  MutualInsAdPageVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsAdPageVC.h"
#import "MutualInsAdPicVC.h"
#import "HomePageVC.h"

@interface MutualInsAdPageVC () <UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UIPageViewController *pageVC;
@property (strong, nonatomic) NSArray *viewArr;
@property (strong, nonatomic) MutualInsAdModel *model;

@end

@implementation MutualInsAdPageVC

-(void)dealloc
{
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    @weakify(self)
    [self setupPageVC];
    [self setupUI];
    
    [RACObserve(self.model, imgStr)subscribeNext:^(NSString *imgStr) {
        @strongify(self)
        if (self.model.imgArr.count != 0)
        {
            for (UIImage *img in self.model.imgArr)
            {
                NSInteger index = img.customTag;
                MutualInsAdPicVC *vc = [self.viewArr safetyObjectAtIndex:index];
                vc.img = img;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

-(void)setupPageVC
{
    [self addChildViewController:self.pageVC];
    [self.pageView addSubview:self.pageVC.view];
    [self.pageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

-(void)setupUI
{
    self.pageControl.numberOfPages = self.viewArr.count;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray* )previousViewControllers transitionCompleted:(BOOL)completed
{
    self.pageControl.currentPage = [self.viewArr indexOfObject:self.pageVC.viewControllers.firstObject];
    if (self.pageControl.currentPage == self.model.imgCount - 1)
    {
        self.tapGesture.enabled = YES;
    }
    else
    {
        self.tapGesture.enabled = NO;
    }
}

#pragma mark - UIPageViewControllerDataSource

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index=[self.viewArr indexOfObject:viewController];
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
    NSInteger index=[self.viewArr indexOfObject:viewController];
    if (index == self.viewArr.count - 1)
    {
        return nil;
    }
    else
    {
        return self.viewArr[index + 1];
    }
}


#pragma mark - Utility

+ (instancetype)presentWithModel:(MutualInsAdModel *)model
{
    MutualInsAdPageVC *vc = [UIStoryboard vcWithId:@"MutualInsAdPageVC" inStoryboard:@"Temp_YZC"];
    if (model.imgCount != 0)
    {
        vc.model = model;
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:gAppMgr.deviceInfo.screenSize viewController:vc];
        [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
        sheet.shadowRadius = 0;
        sheet.shadowOpacity = 0;
        sheet.transitionStyle = MZFormSheetTransitionStyleBounce;
        sheet.shouldDismissOnBackgroundViewTap = NO;
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[vc.tapGesture rac_gestureSignal]subscribeNext:^(id x) {
            [sheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                
                if (model.adLink.length > 0)
                {
                    [gAppMgr.navModel pushToViewControllerByUrl:model.adLink];
                }
            }];
        }];
    }
    return vc;
}

#pragma mark - LazyLoad

-(UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture)
    {
        _tapGesture = [[UITapGestureRecognizer alloc]init];
        _tapGesture.enabled = NO;
        [self.view addGestureRecognizer:_tapGesture];
    }
    return _tapGesture;
}


-(UIPageViewController *)pageVC
{
    if (!_pageVC)
    {
        _pageVC = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageVC.dataSource = self;
        _pageVC.delegate = self;
        
        if (self.viewArr.firstObject)
        {
            [_pageVC setViewControllers:@[self.viewArr.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }
    }
    return _pageVC;
}

-(NSArray *)viewArr
{
    if (!_viewArr)
    {
        NSMutableArray *tempArr = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i < self.model.imgCount; i++)
        {
            MutualInsAdPicVC *vc = [UIStoryboard vcWithId:@"MutualInsAdPicVC" inStoryboard:@"Temp_YZC"];
            
            vc.userInteractionEnabled = ( i == self.model.imgCount - 1 );
            
            [tempArr addObject:vc];
        }
        _viewArr = [NSArray arrayWithArray:tempArr];
    }
    return _viewArr;
}


@end
