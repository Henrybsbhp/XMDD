//
//  AreaTablePickerVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetAreaInfoOp.h"
#import "getAreaByPcdOp.h"

typedef NS_ENUM(NSInteger, PickerVCType) {
    PickerVCTypeProvinceAndCityAndDicstrict,  //默认选择省市区
    PickerVCTypeProvinceAndCity               //只选择省市
};

typedef NS_ENUM(NSInteger, LocateState) {
    LocateStateLocating,    //定位中
    LocateStateSuccess,     //定位成功
    LocateStateFailure      //定位失败
};

@interface AreaTablePickerVC : HKViewController

@property (nonatomic, copy)void(^selectCompleteAction)(HKAreaInfoModel *provinceModel, HKAreaInfoModel *cityModel, HKAreaInfoModel *districtModel);

@property (nonatomic, assign)PickerVCType pickerType;

@property (nonatomic)NSInteger areaId;

@property (nonatomic, strong)NSMutableArray * selectedArray;

@property (nonatomic, strong)UIViewController * originVC;

+ (AreaTablePickerVC *)initPickerAreaVCWithType:(PickerVCType)pickerType fromVC:(UIViewController *)originvVC;

@end
