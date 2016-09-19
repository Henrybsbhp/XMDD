//
//  MutInsCalculatePageVC.m
//  XMDD
//
//  Created by RockyYe on 16/9/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutInsCalculatePageVC.h"
#import "HKPageSliderView.h"
#import "MutInsCalculateVC.h"
#import "MyCarStore.h"

#define kOtherCarTitle @"其他车辆"

@interface MutInsCalculatePageVC () <PageSliderDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) MyCarStore *carStore;
@property (strong, nonatomic) HKMyCar *defaultSelectCar;
@property (assign, nonatomic) RACDisposable *offsetDisposable;
@property (strong, nonatomic) HKPageSliderView *pageController;
@property (strong, nonatomic) NSArray *datasource;
@property (assign, nonatomic) NSInteger currentIndex;



@end

@implementation MutInsCalculatePageVC

- (void)dealloc
{
    DebugLog(@"MutInsCalculatePageVC dealloc");
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.router.disableInteractivePopGestureRecognizer = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigation];
    [self setupDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

- (void)setupNavigation
{
    self.navigationItem.title = @"费用试算";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
}

- (void)setupDataSource
{
    if (gAppMgr.myUser)
    {
        self.headView.hidden = NO;
        // 设置数据源&获取所有爱车
        [self setupCarStore];
        [[self.carStore getAllCars] send];
        
    }
    else
    {
        self.headView.hidden = YES;
        [self setupScrollView];
    }
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
    
    NSMutableArray * tArray = [NSMutableArray array];
    NSArray * licenceArray = [[self.carStore.cars allObjects] arrayByMappingOperator:^id(HKMyCar * car) {
        
        return car.licencenumber;
    }];
    [tArray safetyAddObjectsFromArray:licenceArray];
    if (licenceArray.count < 5)
    {
        [tArray safetyAddObject:kOtherCarTitle];
    }
    
    self.pageController = nil;
    self.pageController.delegate = nil;
    self.pageController.contentScrollView.delegate = nil;
    [self.offsetDisposable dispose];
    
    HKPageSliderView *pageSliderView = [[HKPageSliderView alloc] initWithFrame:self.headView.frame andTitleArray:tArray andStyle:HKTabBarStyleCleanMenu atIndex:current];
    self.pageController = pageSliderView;
    self.pageController.delegate = self;
    self.pageController.hidden = total <= 1;
    [self.headView removeSubviews];
    
    self.headViewHeight.constant = total <= 1 ? 0 : 50;
    
    self.pageController.center = self.headView.center;
    [self.headView addSubview:self.pageController];
}

- (void)setupScrollView
{
    self.view.backgroundColor = [UIColor colorWithHex:@"#f7f7f8" alpha:1.0f];
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    if (gAppMgr.myUser)
    {
        [self observeScrollViewOffset];
    }
    else
    {
        [self createIllegalWithoutLogin];
    }
}

#pragma mark - Utility

- (void)refreshScrollView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger i = 0; i < self.datasource.count; i++)
    {
        NSString * obj = [self.datasource safetyObjectAtIndex:i];
        [self createIllegalCardWithCar:obj];
    }
    
    if (self.datasource.count < 5)
    {
        [self createIllegalCardWithCar:nil];
    }
    
    NSInteger index = NSNotFound;
    
    if (self.defaultSelectCar)
    {
        index = [self.datasource indexOfObject:self.defaultSelectCar];
    }
    if (index == NSNotFound)
    {
        index = 0;
    }
    
    self.currentIndex = index;
    
    CKAsyncMainQueue(^{
        [self loadPageIndex:index animated:NO];
    });
}

- (void)createIllegalWithoutLogin
{
    MutInsCalculateVC * itemVc = [UIStoryboard vcWithId:@"MutInsCalculateVC" inStoryboard:@"MutualInsJoin"];
    [itemVc.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [itemVc didMoveToParentViewController:self];
    [self addChildViewController:itemVc];
    [self.view addSubview:itemVc.view];
    [self.view bringSubviewToFront:itemVc.view];
}

- (void)createIllegalCardWithCar:(NSObject *)car
{
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h= CGRectGetHeight(self.view.frame) - self.headView.frame.size.height;
    CGFloat x = self.scrollView.subviews.count * w;
    
    self.scrollView.contentSize = CGSizeMake(x + w, h);
    
    MutInsCalculateVC * itemVc = [UIStoryboard vcWithId:@"MutInsCalculateVC" inStoryboard:@"MutualInsJoin"];
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
    [itemVc didMoveToParentViewController:self];
    [self addChildViewController:itemVc];
    
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

/// 设置pageController
- (void)refreshPageController
{
    NSInteger total = self.datasource.count + (self.datasource.count < 5 ? 1 : 0);
    self.pageController.hidden = total <= 1;
}

/// 获得数据
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
        self.headViewHeight.constant = 50;
        HKMyCar *defCar = [self.carStore defalutCar];
        HKMyCar *car;
        if ([event isEqualForName:@"addCar"] && event.object) {
            car = [self.carStore.cars objectForKey:event.object];
        }
        if (!car) {
            car = defCar;
        }
        
        self.datasource = [self.carStore.cars allObjects];
        self.defaultSelectCar = car;
        self.currentIndex = [[self.carStore.cars allObjects] indexOfObject:car];
        [self setupPageController];
        [self setupScrollView];
        [self refreshScrollView];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取爱车信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [[self.carStore getAllCars] send];
        }];
    }];
}

#pragma mark - Action

-(void)actionBack
{
    [MobClick event:@"feiyongshisuan" attributes:@{@"feiyongshisuan":@"feiyongshisuan1"}];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat w = CGRectGetWidth(self.view.frame);
    NSInteger index = scrollView.contentOffset.x / w;
    self.currentIndex = index;
    [self refreshPageController];
    [self.pageController selectAtIndex:index];
}

#pragma mark - PageSliderDelegate

- (void)pageClickAtIndex:(NSInteger)index
{
    self.currentIndex = index;
    [self loadPageIndex:index animated:YES];
}

- (BOOL)observeScrollViewOffset
{
    @weakify(self)
    self.offsetDisposable = [[RACObserve(self.scrollView,contentOffset) distinctUntilChanged] subscribeNext:^(NSValue * value) {
        
        @strongify(self)
        CGPoint p = [value CGPointValue];
        [self.pageController slideOffsetX:p.x andTotleW:self.scrollView.contentSize.width andPageW:gAppMgr.deviceInfo.screenSize.width];
    }];
    
    return YES;
}


@end
