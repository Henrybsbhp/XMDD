//
//  MutualInsModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/24.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "HKMutualGroup.h"

@interface MutualInsModel : NSObject

@property (nonatomic, weak) HKViewController *currentVC;

- (void)popToMutualInsGroupDetailVCWith:(HKMutualGroup *)group;
- (void)popToMutualInsHomeVC;
- (void)popToHomePageVC;

@end
