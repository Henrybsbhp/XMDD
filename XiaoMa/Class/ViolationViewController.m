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


@interface ViolationViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong)NSArray * datasource;
@property (nonatomic,strong) MyCarStore *carStore;

@property (nonatomic)BOOL isloading;

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
        
        [self setupScrollView];
    });
    
    // 设置数据源&获取所有爱车
    [self setupCarStore];
    [self.carStore sendEvent:[self.carStore getAllCars]];
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
    [self.carStore subscribeEventsWithTarget:self receiver:^(HKStore *store, HKStoreEvent *evt) {
        @strongify(self);
        [self reloadDataWithEvent:evt];
    }];
}

- (void)setupScrollView
{
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithHex:@"#f4f4f4" alpha:1.0f];

    @weakify(self);
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)refreshScrollView
{
    CKAsyncMainQueue(^{
        
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
        [self loadPageIndex:index animated:NO];
    });
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
}

- (void)reloadDataWithEvent:(HKStoreEvent *)evt
{
    NSInteger code = evt.code;
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
        if (code == kHKStoreEventAdd) {
            car = x;
        }
        if (!car) {
            car = defCar;
        }
        
        self.datasource = [self.carStore.cache allObjects];
        self.defaultSelectCar  = car;
        [self refreshScrollView];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.view showDefaultEmptyViewWithText:@"获取爱车信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [self.carStore sendEvent:[self.carStore getAllCars]];
        }];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}


@end
