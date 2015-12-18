//
//  PickerAutoModelVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerAutoModelVC : UIViewController

@property (nonatomic, strong) AutoBrandModel *brand;
@property (nonatomic, strong) AutoSeriesModel * series;
@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, copy) void(^completed)(AutoBrandModel *brand, AutoSeriesModel *series, AutoDetailModel * model);

@end
