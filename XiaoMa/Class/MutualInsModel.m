//
//  MutualInsModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/24.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsModel.h"
#import "MutualInsGrouponVC.h"
#import "MutualInsHomeVC.h"

@implementation MutualInsModel


- (void)popToMutualInsGroupDetailVCWith:(HKMutualGroup *)group {
    
    UINavigationController *nav = self.currentVC.navigationController;
    NSMutableArray *vcs = [NSMutableArray array];
    
    NSInteger index = NSNotFound;
    for (NSInteger i=0; i<nav.viewControllers.count; i++) {
        UIViewController *vc = nav.viewControllers[i];
        if ([vc isKindOfClass:[MutualInsHomeVC class]]) {
            index = i;
            break;
        }
    }
    
    if (index != NSNotFound) {
        [vcs safetyAddObjectsFromArray:[nav.viewControllers subarrayToIndex:index]];
    }
    else {
        [vcs addObject:nav.viewControllers[0]];
        MutualInsHomeVC * vc = [UIStoryboard vcWithId:@"MutualInsHomeVC" inStoryboard:@"MutualInsJoin"];
        [vcs addObject:vc];
    }
    
    MutualInsGrouponVC *groupvc = [mutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponVC"];
    groupvc.group = group;
    [vcs addObject:groupvc];
    
    [vcs addObject:self.currentVC];
    nav.viewControllers = vcs;
    [nav popViewControllerAnimated:YES];
}


- (void)popToMutualInsHomeVC {
    
    UINavigationController *nav = self.currentVC.navigationController;
    MutualInsHomeVC *homevc = [nav.viewControllers firstObjectByFilteringOperator:^BOOL(id obj) {
        return [obj isKindOfClass:[MutualInsHomeVC class]];
    }];
    if (homevc) {
        [nav popToViewController:homevc animated:YES];
    }
    else {
        homevc = [UIStoryboard vcWithId:@"MutualInsHomeVC" inStoryboard:@"MutualInsJoin"];
        UIViewController *rootvc = nav.viewControllers[0];
        nav.viewControllers = @[rootvc, homevc, self.currentVC];
        [nav popViewControllerAnimated:YES];
    }
}

- (void)popToHomePageVC {

    UIViewController *curvc = self.currentVC;
    [curvc.tabBarController setSelectedIndex:0];
    UIViewController * firstTabVC = [curvc.tabBarController.viewControllers safetyObjectAtIndex:0];
    [curvc.tabBarController.delegate tabBarController:curvc.tabBarController didSelectViewController:firstTabVC];
    
    [curvc.navigationController popToRootViewControllerAnimated:YES];
}


@end
