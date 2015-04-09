//
//  MainTabBarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MainTabBarVC.h"
#import "XiaoMa.h"

@interface MainTabBarVC ()

@end

@implementation MainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTabBar];
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
