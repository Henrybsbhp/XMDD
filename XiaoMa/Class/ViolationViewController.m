//
//  IllegalViewController.m
//  XiaoMa
//
//  Created by jt on 15/11/23.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "ViolationViewController.h"
#import "ViolationItemViewController.h"
#import "MyCarStore.h"
#import "MyUIPageControl.h"


@interface ViolationViewController ()<UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *headView;
@property (strong,nonatomic)MyUIPageControl * pageController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong)NSArray * datasource;
@property (nonatomic,strong) MyCarStore *carStore;

@property (nonatomic)BOOL isloading;

@property (nonatomic)NSInteger currentIndex;

/// 用于自动跳转到新添加或默认的爱车页面
@property (nonatomic,strong)HKMyCar * defaultSelectCar;

@end

@implementation ViolationViewController

- (void)dealloc
{
    DebugLog(@"ViolationViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigation];
    CKAsyncMainQueue(^{
        
        [self setupPageController];
        [self setupScrollView];
    });
    
    // 设置数据源&获取所有爱车
    [self setupCarStore];
    [[self.carStore getAllCars] send];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup
- (void)setupNavigation
{
    self.navigationItem.title = @"违章查询";
}

- (void)setupCarStore
{
    @weakify(self);
    self.carStore = [MyCarStore fetchOrCreateStore];
    [self.carStore subscribeWithTarget:self domain:@"cars" receiver:^(CKStore *store, CKEvent *evt) {
        
        @strongify(self);
        [self reloadDataWithEvent:evt];
    }];
}

- (void)setupPageController
{
    NSInteger total = self.datasource.count + (self.datasource.count < 5 ? 1 : 0);
    NSInteger current = self.currentIndex;
    
    if (!self.pageController)
    {
        self.pageController = [[MyUIPageControl alloc] init];
    }
    self.pageController.numberOfPages = total;
    self.pageController.currentPage = current;
    self.pageController.hidden = total <= 1;
    
    [self.pageController removeFromSuperview];
    
    UIView * headView = self.headView;
    self.pageController.center = headView.center;
    [headView addSubview:self.pageController];
}

- (void)refreshPageController
{
    NSInteger total = self.datasource.count + (self.datasource.count < 5 ? 1 : 0);
    NSInteger current = self.currentIndex;
    self.pageController.numberOfPages = total;
    self.pageController.currentPage = current;
    self.pageController.hidden = total <= 1;
}

- (void)setupScrollView
{
    self.view.backgroundColor = [UIColor colorWithHex:@"#f4f4f4" alpha:1.0f];
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];

    @weakify(self);
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)refreshScrollView
{
//    CKAsyncMainQueue(^{
    
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (NSInteger i = 0; i < self.datasource.count; i++) {
            
            NSObject * obj = [self.datasource safetyObjectAtIndex:i];
            [self createIllegalCardWithCar:obj];
        }
        
        if (self.datasource.count < 5)
        {
            [self createIllegalCardWithCar:nil];
        }
        
        NSInteger index = NSNotFound;
        
        if (self.defaultSelectCar) {
            index = [self.datasource indexOfObject:self.defaultSelectCar];
        }
        if (index == NSNotFound) {
            index = 0;
        }
    
    self.currentIndex = index;
        [self loadPageIndex:index animated:NO];
//    });
}

- (void)createIllegalCardWithCar:(NSObject *)car
{
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h= CGRectGetHeight(self.view.frame);
    CGFloat x = self.scrollView.subviews.count * w;
    
    self.scrollView.contentSize = CGSizeMake(x + w, h);

    ViolationItemViewController * itemVc = [violationStoryboard instantiateViewControllerWithIdentifier:@"ViolationItemViewController"];
    if ([car isKindOfClass:[HKMyCar class]])
    {
        itemVc.car = (HKMyCar *)car;
        itemVc.carArray = self.datasource;
    }
    else
    {
        itemVc.carArray = self.datasource;
    }
    [itemVc.view setFrame:CGRectMake(x, 0, w, h)];
    [self addChildViewController:itemVc];
    [itemVc didMoveToParentViewController:self];
    
    [self.scrollView addSubview:itemVc.view];
}

- (void)loadPageIndex:(NSUInteger)index animated:(BOOL)animated
{
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGRect frame = self.scrollView.frame;
    frame.origin.x = w * index;
    frame.origin.y = 0;
    
    [self.scrollView scrollRectToVisible:frame animated:animated];
    
    [self refreshPageController];
}

- (void)reloadDataWithEvent:(CKEvent *)evt
{
    CKEvent *event = evt;
    @weakify(self);
    [[[[evt.signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        @strongify(self);
        self.view.indicatorPoistionY = floor((self.view.frame.size.height - 75)/2.0);
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        
        @strongify(self);
        [self.view stopActivityAnimation];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        HKMyCar *defCar = [self.carStore defalutCar];
        HKMyCar *car;
        if ([event isEqualForName:@"addCar"] && event.object) {
            car = [self.carStore.cars objectForKey:event.object];
        }
        if (!car) {
            car = defCar;
        }
        
        self.datasource = [self.carStore.cars allObjects];
        self.defaultSelectCar  = car;
        [self refreshScrollView];
        [self setupPageController];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.view showDefaultEmptyViewWithText:@"获取爱车信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [[self.carStore getAllCars] send];
        }];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat w = CGRectGetWidth(self.view.frame);
    NSInteger index = scrollView.contentOffset.x / w;
    self.currentIndex = index;
    [self refreshPageController];
}


@end
