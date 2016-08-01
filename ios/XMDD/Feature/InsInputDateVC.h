//
//  InsInputDateVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsuranceVM.h"
#import "AddInsCarBaseInfoOp.h"

@interface InsInputDateVC : HKViewController
@property (nonatomic, strong) InsuranceVM *insModel;
@property (nonatomic, strong) AddInsCarBaseInfoOp *insCarInfo;

@end
