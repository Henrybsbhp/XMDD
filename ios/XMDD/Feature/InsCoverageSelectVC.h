//
//  InsCoverageSelectVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/23.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsuranceVM.h"
#import "InsuranceAppointmentV3Op.h"

typedef NS_ENUM(NSInteger, InsuranceSelectMode) {
    InsuranceSelectModeBuy,
    InsuranceSelectModeAppointment
};

@interface InsCoverageSelectVC : HKViewController

@property (nonatomic, strong) InsuranceVM *insModel;
@property (nonatomic, assign) InsuranceSelectMode selectMode;
@property (nonatomic, strong) InsuranceAppointmentV3Op *appointmentOp;

@end
