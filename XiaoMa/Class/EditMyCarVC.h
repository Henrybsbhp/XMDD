//
//  EditMyCarVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"

@interface EditMyCarVC : UIViewController

@property (nonatomic, strong, readonly) HKMyCar *originCar;

- (void)reloadWithOriginCar:(HKMyCar *)originCar;

@end
