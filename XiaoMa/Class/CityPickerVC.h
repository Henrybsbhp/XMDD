//
//  CityPickerVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Area.h"

typedef enum : NSUInteger
{
    CityPickerOptionNone = 0,
    CityPickerOptionProvince = 1 << 0,
    CityPickerOptionCity = 1 << 1,
    CityPickerOptionDistrict = 1 << 2,
    CityPickerOptionGPS = 1 << 3
    
}CityPickerOptionsMask;

@interface CityPickerVC : HKViewController

@property (nonatomic, strong) Area *parentArea;
@property (nonatomic, assign) CityPickerOptionsMask options;
@property (nonatomic, copy) void(^completedBlock)(CityPickerVC *vc, Area *province, Area *city, Area *district);

+ (instancetype)cityPickerVCWithOriginVC:(UIViewController *)originVC;

@end
