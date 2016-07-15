//
//  MutualInsAdPageVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsAdPageVC.h"
#import "MutualInsAdPicVC.h"


@interface MutualInsAdPageVC () <UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (strong, nonatomic) UIPageViewController *pageVC;
@property (strong, nonatomic) NSArray *viewArr;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation MutualInsAdPageVC

-(void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupPageVC];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network

- (RACSignal *)rac_getImageByUrl:(NSString *)strurl withType:(ImageURLType)type
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *realStrUrl = [gMediaMgr urlWith:strurl imageType:type];
        NSURL *url = strurl ? [NSURL URLWithString:realStrUrl] : nil;
        SDWebImageManager *mgr = [SDWebImageManager sharedManager];
        if (url && ![mgr cachedImageExistsForURL:url]) {
            [subscriber sendNext:nil];
        }
        [mgr downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                [subscriber sendNext:image];
            }
            else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }] deliverOn:[RACScheduler mainThreadScheduler]];
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
    self.pageControl.numberOfPages = 5;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray* )previousViewControllers transitionCompleted:(BOOL)completed
{
    self.pageControl.currentPage = [self.viewArr indexOfObject:self.pageVC.viewControllers.firstObject];
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

+ (instancetype)presentInTargetVC:(UIViewController *)targetVC
{
    MutualInsAdPageVC *vc = [UIStoryboard vcWithId:@"MutualInsAdPageVC" inStoryboard:@"Temp_YZC"];
    vc.targetVC = targetVC;
    
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:gAppMgr.deviceInfo.screenSize viewController:vc];
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    sheet.shouldDismissOnBackgroundViewTap = NO;
    sheet.shouldCenterVertically = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [[vc.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    
    return vc;
}

#pragma mark - LazyLoad

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
        NSMutableArray *tempArr = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i < 5; i++)
        {
            MutualInsAdPicVC *vc = [UIStoryboard vcWithId:@"MutualInsAdPicVC" inStoryboard:@"Temp_YZC"];
            
            vc.userInteractionEnabled = i == 4;
            
            [[self rac_getImageByUrl:[NSString stringWithFormat:@"http://7xjclc.com1.z0.glb.clouddn.com/android_step_%ld.png",i + 1] withType:ImageURLTypeOrigin]subscribeNext:^(UIImage *img) {
                vc.img = img;
            }];
            
            [tempArr addObject:vc];
        }
        _viewArr = [NSArray arrayWithArray:tempArr];
    }
    return _viewArr;
}


@end
