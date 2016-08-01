//
//  InsAppointmentVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsuranceVM.h"
#import "InsPremium.h"

@interface InsAppointmentVC : HKViewController

@property (nonatomic, strong) InsuranceVM *insModel;
@property (nonatomic, strong) InsPremium *insPremium;

@end
