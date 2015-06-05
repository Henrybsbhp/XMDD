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

@interface MainTabBarVC ()<UITabBarControllerDelegate>

@end

@implementation MainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    [self setupTabBar];
    gAppDelegate.curNavCtrl = [self.viewControllers safetyObjectAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTabBar
{
    static NSString *selectedImages[] = {@"tab_home1", @"tab_nearby1", @"tab_mine1"};
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        item.selectedImage = [UIImage imageNamed:selectedImages[i]];
    }
    //"我的"
    [[[RACObserve(gAppMgr, myUser) distinctUntilChanged] flattenMap:^RACStream *(JTUser *user) {
        
        if (user) {
            return [RACObserve(user, hasNewMsg) distinctUntilChanged];
        }
        return [RACSignal return:@NO];
    }] subscribeNext:^(NSNumber *hasmsg) {
        
        BOOL showDot = [hasmsg boolValue];
        if (showDot) {
            CGFloat x = ceilf(CGRectGetWidth(self.tabBar.frame)/6*5 + 6);
            CGFloat y = 6;
            [self.tabBar showDotWithOffset:CGPointMake(x, y)];
        }
        else {
            [self.tabBar hideDot];
        }
    }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSString * str = [NSString stringWithFormat:@"rp101-%ld",(long)viewController.tabBarItem.tag];
    [MobClick event:str];
    NSLog(@"%@",str);
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        gAppDelegate.curNavCtrl = (UINavigationController *)viewController;
    }
    else {
        gAppDelegate.curNavCtrl = viewController.navigationController;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
