//
//  PickCarVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/4/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCarListVModel.h"

@interface PickCarVC : HKViewController

@property (nonatomic, assign) BOOL isShowBottomView;

@property (nonatomic, assign) HKMyCar *defaultCar;
@property (nonatomic, strong) MyCarListVModel *model;

@property (nonatomic, copy) void(^finishPickCar)(MyCarListVModel *carModel, UIView * loadingView);

@end
