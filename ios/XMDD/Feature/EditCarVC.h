//
//  EditCarVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"
#import "MyCarListVModel.h"

@interface EditCarVC : HKViewController

@property (nonatomic, strong) HKMyCar *originCar;
@property (nonatomic, strong) NSNumber *originCarId;
@property (nonatomic, strong) MyCarListVModel *model;

@end
