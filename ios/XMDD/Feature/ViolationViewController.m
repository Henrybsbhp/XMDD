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
#import "HKPageSliderView.h"

#define kAddCarTitle @"添加爱车"


@interface ViolationViewController ()<UIScrollViewDelegate,PageSliderDelegate>


@property (weak, nonatomic) IBOutlet UIView *headView;
@property (strong,nonatomic)HKPageSliderView * pageController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong)NSArray * datasource;
@property (nonatomic,strong) MyCarStore *carStore;

@property (nonatomic)BOOL isloading;

@property (nonatomic)NSInteger currentIndex;

@property (nonatomic,strong)RACDisposable * offsetDisposable;

/// 用于自动跳转到新添加或默认的爱车页面
@property (nonatomic,strong)HKMyCar * defaultSelectCar;

@end

@implementation ViolationViewController

- (void)dealloc
{
    DebugLog(@"ViolationViewController dealloc");
}

- (void)awakeFromNib {
    self.router.disableInteractivePopGestureRecognizer = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigation];
    
    // 设置数据源&获取所有爱车
    [self setupCarStore];
    [[self.carStore getAllCars] send];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup
- (void)setupNavigation
{
    self.navigationItem.title = @"违章查询";
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"我的代办" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(jumpToMyVoilationMissionHistoryV:)];
    [right setTitleTextAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                                    } forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = right;
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
        [tArray safetyAddObject:kAddCarTitle];
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
    
    if (total <= 1)
    {
        [self.headView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.height.equalTo(@0);
        }];
    }else
    {
        [self.headView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.height.equalTo(@50);
        }];
    }
    
    self.pageController.center = self.headView.center;
    [self.headView addSubview:self.pageController];
}

- (void)setupScrollView
{
    self.view.backgroundColor = [UIColor colorWithHex:@"#f7f7f8" alpha:1.0f];
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [self observeScrollViewOffset];
}

#pragma mark - Utility
/// 跳转到违章记录VC
- (void)jumpToMyVoilationMissionHistoryVC
{
    
}

- (void)refreshPageController
{
    NSInteger total = self.datasource.count + (self.datasource.count < 5 ? 1 : 0);
    self.pageController.hidden = total <= 1;
}



- (void)refreshScrollView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger i = 0; i < self.datasource.count; i++) {
        
        NSString * obj = [self.datasource safetyObjectAtIndex:i];
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
    
    CKAsyncMainQueue(^{
        [self loadPageIndex:index animated:NO];
    });
    
}

- (void)createIllegalCardWithCar:(NSObject *)car
{
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h= CGRectGetHeight(self.view.frame) - self.headView.frame.size.height;
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
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

#pragma mark Action

- (IBAction)actionJumpToRecord:(id)sender {
    
}


@end
