//
//  InsPayResultVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKInsuranceOrder.h"
#import "InsuranceVM.h"

@interface InsPayResultVC : UIViewController

@property (nonatomic, strong) InsuranceVM *insModel;
@property (nonatomic, strong) HKInsuranceOrder *insOrder;

@end
