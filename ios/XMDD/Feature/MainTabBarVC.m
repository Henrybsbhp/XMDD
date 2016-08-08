//
//  MainTabBarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MainTabBarVC.h"
#import "Xmdd.h"
#import "UIView+ShowDot.h"
#import "GuideStore.h"
#import "DTouchButton.h"

@interface MainTabBarVC ()<UITabBarControllerDelegate>
@property (nonatomic, strong)GuideStore *guideStore;
@property (nonatomic, strong)DTouchButton * assistiveBtn;
@end

@implementation MainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    [self setupTabBar];
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

- (void)setupTabBar
{
    //"我的"
    RACSignal *signal = [[RACObserve(gAppMgr, myUser) distinctUntilChanged] flattenMap:^RACStream *(JTUser *user) {
        
        if (user) {
            return [RACObserve(user, hasNewMsg) distinctUntilChanged];
        }
        return [RACSignal return:@NO];
    }];
    [self reloadMineTabDotWith:signal];
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
- (void)reloadMineTabDotWith:(RACSignal *)signal
{
    @weakify(self);
    [signal subscribeNext:^(id x) {
        @strongify(self);
        if (self.guideStore.shouldShowNewbieGuideDot || gAppMgr.myUser.hasNewMsg) {
            CGFloat offsetX = 3;
            CGFloat offsetY = 5;
            if (!IOSVersionGreaterThanOrEqualTo(@"7.0")) {
                offsetX = 7;
                offsetY = 5;
            }
            CGFloat x = ceilf(CGRectGetWidth(self.tabBar.frame)/6*5 + offsetX);
            CGFloat y = offsetY;
            [self.tabBar showDotWithOffset:CGPointMake(x, y)];
        }
        else {
            [self.tabBar hideDot];
        }
    }];
}

#pragma mark - Delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSString * str = [NSString stringWithFormat:@"rp101_%ld",(long)viewController.tabBarItem.tag];
    [MobClick event:str];
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        gAppMgr.navModel.curNavCtrl = (UINavigationController *)viewController;
    }
    else {
        gAppMgr.navModel.curNavCtrl = viewController.navigationController;
    }
}


@end
