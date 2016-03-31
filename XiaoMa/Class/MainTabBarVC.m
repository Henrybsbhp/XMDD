//
//  MainTabBarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MainTabBarVC.h"
#import "XiaoMa.h"
#import "UIView+ShowDot.h"
#import "GuideStore.h"

@interface MainTabBarVC ()<UITabBarControllerDelegate>
@property (nonatomic, strong) GuideStore *guideStore;
@end

@implementation MainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    [self setupTabBar];
    gAppMgr.navModel.curNavCtrl = [self.viewControllers safetyObjectAtIndex:0];
    [self setupGuideStore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTabBar
{
    static NSString *selectedImages[] = {@"tab_home_highlighted_300", @"tab_discover_highlighted_300", @"tab_mine_highlighted_300"};
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        item.selectedImage = [UIImage imageNamed:selectedImages[i]];
    }
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
    NSLog(@"%@",str);
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        gAppMgr.navModel.curNavCtrl = (UINavigationController *)viewController;
    }
    else {
        gAppMgr.navModel.curNavCtrl = viewController.navigationController;
    }
    [self.customNavCtrl setNeedsStatusBarAppearanceUpdate];
}


@end
