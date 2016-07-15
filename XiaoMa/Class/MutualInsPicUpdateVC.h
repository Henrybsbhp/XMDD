//
//  MutualInsPicUpdateVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"

@interface MutualInsPicUpdateVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;

/// 车(带入的车辆必须包含id和lisenceNumber)
@property (nonatomic,strong)HKMyCar * curCar;
/// 成员id(重新上传或者自助团会有此值)
@property (nonatomic,strong)NSNumber * memberId;
/// 团id，用于自主团
@property (nonatomic,strong)NSNumber * groupId;

@end
