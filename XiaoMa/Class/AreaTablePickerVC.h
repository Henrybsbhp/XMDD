//
//  AreaTablePickerVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetAreaInfoOp.h"

@interface AreaTablePickerVC : UIViewController

@property (nonatomic, copy)void(^selectCompleteAction)(HKAreaInfoModel *provinceModel, HKAreaInfoModel *cityModel, HKAreaInfoModel *disctrictModel);

@property (nonatomic, assign)AreaType areaType;
@property (nonatomic)NSInteger areaId;

@property (nonatomic, strong)NSMutableArray * selectedArray;

@property (nonatomic, strong)UIViewController * originVC;

@end
