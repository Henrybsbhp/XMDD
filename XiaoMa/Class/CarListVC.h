//
//  CarListVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"
#import "MyCarListVModel.h"

@interface CarListVC : UIViewController

@property (nonatomic, strong, readonly) MyCarListVModel *model;
@property (nonatomic, strong) NSNumber *originCarID;

@end
