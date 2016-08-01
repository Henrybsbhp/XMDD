//
//  MutualInsPickCarVC.h
//  XiaoMa
//
//  Created by fuqi on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"

@interface MutualInsPickCarVC : UIViewController

@property (nonatomic, copy) void(^finishPickCar)(HKMyCar *car);

@property (nonatomic,strong)NSArray * mutualInsCarArray;

@end
