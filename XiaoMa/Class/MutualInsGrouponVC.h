//
//  MutualInsGrouponVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "HKMutualGroup.h"

@interface MutualInsGrouponVC : HKViewController

@property (nonatomic, strong)HKMutualGroup * group;

@property (nonatomic, weak)UIViewController * originVC;

- (void)requestGroupDetailInfo;

@end
