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


@interface CarListVC : HKViewController

@property (nonatomic, strong, readonly) MyCarListVModel *model;
@property (nonatomic, strong) NSNumber *originCarID;

@property (nonatomic, strong) UIViewController * originVC;

@property (strong, nonatomic)void(^finishPickActionForMutualIns)(HKMyCar * car,UIView * loadingView);

@end
