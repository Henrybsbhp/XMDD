//
//  PickerAutomobileBrandVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"

@interface PickerAutomobileBrandVC : UIViewController
@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, strong) HKMyCar *car;
@end
