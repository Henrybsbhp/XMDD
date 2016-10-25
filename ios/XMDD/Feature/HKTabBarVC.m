//
//  HKTabBarVC.m
//  XMDD
//
//  Created by fuqi on 16/9/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTabBarVC.h"
#import "UIView+ShowDot.h"
#import "GuideStore.h"
#import "DTouchButton.h"
#import "HKNavigationController.h"
#import "HomePageVC.h"
#import "MutualPlanViewController.h"
#import "ListWebVC.h"
#import "MineVC.h"

#import "JTImageBadge.h"

@interface HKTabBarVC()<UITabBarControllerDelegate>

@property (nonatomic, strong)GuideStore *guideStore;
@property (nonatomic, strong)DTouchButton * assistiveBtn;

@property (nonatomic, strong)HKNavigationController * mutualPlanNavigationVC;

/// 互助计划小红点
@property (nonatomic)BOOL isMutualPlanDot;

@property (nonatomic,strong)JTImageBadge * mutualPlanDot;
@property (nonatomic,strong)JTImageBadge * mineDot;

@end

@implementation HKTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDatasource];
    
    [self setupTabbar];
    [self setupTabDot];
    gAppMgr.navModel.curNavCtrl = [self.viewControllers safetyObjectAtIndex:0];
    [self setupGuideStore];
    
#ifdef DEBUG
    [self setupAssistiveTouchView];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDatasource
{
    gAppMgr.huzhuTabFlag = [gAppMgr loadLastMutualPlanTabAppear];
    self.isMutualPlanDot = ![gAppMgr getElementReadStatus:AppMutualPlanDot];
}

- (void)setupTabbar
{
    HomePageVC * homePageVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomePageVC"];
    MutualPlanViewController * mutualPlanVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MutualPlanViewController"];
    ListWebVC * listWebVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ListWebVC"];
    MineVC * mineVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MineVC"];
    
    UITabBarItem * tabbarItem1 = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"tab_home_300"] selectedImage:[UIImage imageNamed:@"tab_home_highlighted_300"]];
    tabbarItem1.titlePositionAdjustment = UIOffsetMake(0, -3);
    tabbarItem1.tag = 1;
    
    UITabBarItem * tabbarItem2 = [[UITabBarItem alloc] initWithTitle:@"互助" image:[UIImage imageNamed:@"tab_mutualplan_300"] selectedImage:[UIImage imageNamed:@"tab_mutualplan_highlighted_300"]];
    tabbarItem2.titlePositionAdjustment = UIOffsetMake(0, -3);
    tabbarItem2.tag = 2;
    
    UITabBarItem * tabbarItem3 = [[UITabBarItem alloc] initWithTitle:@"活动" image:[UIImage imageNamed:@"tab_discover_300"] selectedImage:[UIImage imageNamed:@"tab_discover_highlighted_300"]];
    tabbarItem3.titlePositionAdjustment = UIOffsetMake(0, -3);
    tabbarItem3.tag = 3;
    
    UITabBarItem * tabbarItem4 = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"tab_mine_300"] selectedImage:[UIImage imageNamed:@"tab_mine_highlighted_300"]];
    tabbarItem4.titlePositionAdjustment = UIOffsetMake(0, -3);
    tabbarItem4.tag = 4;
    
    HKNavigationController * navigationVC1 = [[HKNavigationController alloc] initWithRootViewController:homePageVC];
    HKNavigationController * navigationVC2 = [[HKNavigationController alloc] initWithRootViewController:mutualPlanVC];
    HKNavigationController * navigationVC3 = [[HKNavigationController alloc] initWithRootViewController:listWebVC];
    HKNavigationController * navigationVC4 = [[HKNavigationController alloc] initWithRootViewController:mineVC];
    
    navigationVC1.edgesForExtendedLayout = UIRectEdgeNone;
    navigationVC2.edgesForExtendedLayout = UIRectEdgeNone;
    navigationVC3.edgesForExtendedLayout = UIRectEdgeNone;
    navigationVC4.edgesForExtendedLayout = UIRectEdgeNone;
    
    navigationVC1.tabBarItem = tabbarItem1;
    navigationVC2.tabBarItem = tabbarItem2;
    navigationVC3.tabBarItem = tabbarItem3;
    navigationVC4.tabBarItem = tabbarItem4;
    
    self.mutualPlanNavigationVC = navigationVC2;
    
    if (gAppMgr.huzhuTabFlag)
    {
        self.viewControllers = @[navigationVC1,navigationVC2,navigationVC3,navigationVC4];
    }
    else
    {
        self.viewControllers = @[navigationVC1,navigationVC3,navigationVC4];
    }
    
    self.delegate = self;
    self.tabBar.translucent = NO;
}

- (void)setupTabDot
{
    //"我的"
    RACSignal *signal = [[RACObserve(gAppMgr, myUser) distinctUntilChanged] flattenMap:^RACStream *(JTUser *user) {
        
        if (user) {
            return [RACObserve(user, hasNewMsg) distinctUntilChanged];
        }
        return [RACSignal return:@NO];
    }];
    [self reloadMineTabDotWith:signal];
    
    [self reloadAppearMutualPlanDot];
}

- (void)setupGuideStore
{
    self.guideStore = [GuideStore fetchOrCreateStore];
    @weakify(self);
    [self.guideStore subscribeWithTarget:self domain:kDomainNewbiewGuide receiver:^(CKStore *store, CKEvent *evt) {
        
        @strongify(self);
        //刷新小圆点
        [self reloadMineTabDotWith:[evt signal]];
    }];
}

- (void)setupAssistiveTouchView
{
    if (!self.assistiveBtn)
    {
        DTouchButton * assistiveBtn = [[DTouchButton alloc] initWithFrame:CGRectMake(0, 64, 44, 44)];
        assistiveBtn.userInteractionEnabled = YES;
        assistiveBtn.userInteractionEnabled_DT = YES;
        [self.view addSubview:assistiveBtn];
        
        self.assistiveBtn = assistiveBtn;
    }
    
    @weakify(self)
    [[[self.assistiveBtn rac_signalForSelector:@selector(tapGestureRecognizer)] flattenMap:^RACStream *(id value) {
        
        @strongify(self)
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"辅助功能" delegate:nil cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil otherButtonTitles:@"上传日志",@"实时日志",gAssistiveMgr.isRecordLog ? @"停止日志录制":@"日志录制",@"FPS开关",nil];
        [sheet showInView:self.view];
        return [sheet rac_buttonClickedSignal];
    }] subscribeNext:^(NSNumber *x) {
        
        NSInteger index = [x integerValue];
        if (index == 0)
        {
            [gAssistiveMgr uploadLog];
        }
        else if (index == 1)
        {
            [gAssistiveMgr switchShowLogWithAlertView];
        }
        else if (index == 2)
        {
            [gAssistiveMgr switchShowLogWithTableVC];
        }
        else if (index == 3)
        {
            [gAssistiveMgr showFPSObserver];
        }
    }];
    
    [RACObserve(gAssistiveMgr, isShowAssistiveView) subscribeNext:^(NSNumber * number) {
        
        BOOL flag = [number integerValue];
        self.assistiveBtn.hidden  = !flag;
    }];
}

#pragma mark - Reload
- (void)reloadTabBarVC
{
    NSMutableArray * vcs = [NSMutableArray arrayWithArray:self.viewControllers];
    if (gAppMgr.huzhuTabFlag && vcs.count == 3)
    {
        [vcs safetyInsertObject:self.mutualPlanNavigationVC atIndex:1];
    }
    else if (!gAppMgr.huzhuTabFlag && vcs.count == 4)
    {
        [vcs safetyRemoveObjectAtIndex:1];
    }
    self.viewControllers = [NSArray arrayWithArray:vcs];
    
    [self reloadAppearMineTabDot];
    
    [self reloadAppearMutualPlanDot];
}


- (void)reloadMineTabDotWith:(RACSignal *)signal
{
    @weakify(self);
    [signal subscribeNext:^(id x) {
        @strongify(self);
        [self reloadAppearMineTabDot];
    }];
}

/// tab个数会导致红点错位
- (void)reloadAppearMineTabDot
{
    if (self.guideStore.shouldShowNewbieGuideDot || gAppMgr.myUser.hasNewMsg) {
        
        CGFloat offsetX = 3;
        CGFloat offsetY = 5;
        if (!IOSVersionGreaterThanOrEqualTo(@"7.0")) {
            offsetX = 7;
            offsetY = 5;
        }
        
        NSInteger count = self.viewControllers.count;
        NSInteger doubleCount = count * 2;
        CGFloat x = ceilf(CGRectGetWidth(self.tabBar.frame)/doubleCount*(doubleCount-1) + offsetX);
        CGFloat y = offsetY;
        [self.tabBar showDotWithOffset:CGPointMake(x, y) withBadge:self.mineDot];
    }
    else {
        [self.tabBar hideDotWithBadge:self.mineDot];
    }
}

- (void)reloadAppearMutualPlanDot
{
    if (self.isMutualPlanDot && self.viewControllers.count == 4)
    {
        CGFloat offsetX = 3;
        CGFloat offsetY = 5;
        if (!IOSVersionGreaterThanOrEqualTo(@"7.0")) {
            offsetX = 7;
            offsetY = 5;
        }
        CGFloat x = ceilf(CGRectGetWidth(self.tabBar.frame)/8*3 + offsetX);
        CGFloat y = offsetY;
        [self.tabBar showDotWithOffset:CGPointMake(x, y) withBadge:self.mutualPlanDot];
    }
    else
    {
        [self.tabBar hideDotWithBadge:self.mutualPlanDot];
    }
}

#pragma mark - Delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSString * str = [NSString stringWithFormat:@"yingyongtabbar_%ld",(long)viewController.tabBarItem.tag];
    [MobClick event:str];
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        gAppMgr.navModel.curNavCtrl = (UINavigationController *)viewController;
    }
    else {
        gAppMgr.navModel.curNavCtrl = viewController.navigationController;
    }
    
    if (viewController.tabBarItem.tag == 2 && self.isMutualPlanDot)
    {
        [self.tabBar hideDotWithBadge:self.mutualPlanDot];
        self.isMutualPlanDot = NO;
        [gAppMgr saveElementReaded:AppMutualPlanDot];
        
    }
}

- (JTImageBadge *)mutualPlanDot
{
    if (!_mutualPlanDot)
    {
        _mutualPlanDot = [[JTImageBadge alloc] initWithFrame:CGRectZero];
        _mutualPlanDot.center = CGPointMake(0, 0);
    }
    return _mutualPlanDot;
}

- (JTImageBadge *)mineDot
{
    if (!_mineDot)
    {
        _mineDot = [[JTImageBadge alloc] initWithFrame:CGRectZero];
        _mineDot.center = CGPointMake(0, 0);
    }
    return _mineDot;
}


@end
