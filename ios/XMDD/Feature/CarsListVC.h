//
//  CarsListVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"
#import "MyCarListVModel.h"

@interface CarsListVC : HKViewController

@property (nonatomic, strong, readonly) MyCarListVModel *model;
@property (nonatomic, strong) NSNumber *originCarID;

@property (nonatomic, copy)void(^finishPickActionForMutualIns)(MyCarListVModel * model, UIView * loadingView);

@end
