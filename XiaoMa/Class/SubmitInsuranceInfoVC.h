//
//  SubmitInsuranceInfoVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/25.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"

@interface SubmitInsuranceInfoVC : UIViewController
@property (nonatomic, strong) NSString *calculateID;
@property (nonatomic, strong) HKMyCar *car;
@property (nonatomic, assign) BOOL shouldUpdateCar;
@property (nonatomic, weak) UIViewController *originVC;

@end
