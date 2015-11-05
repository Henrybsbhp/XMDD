//
//  CarwashOrderDetailVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKServiceOrder.h"

@interface CarwashOrderDetailVC : UIViewController
@property (nonatomic, strong) HKServiceOrder *order;
@property (nonatomic, strong) NSNumber *orderID;

@property (nonatomic, weak) UIViewController *originVC;
@end
