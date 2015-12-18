//
//  ValuationResultVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/17.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarEvaluateOp.h"

@interface ValuationResultVC : UIViewController

@property (nonatomic, strong)CarEvaluateOp * evaluateOp;

@property (nonatomic, strong)NSString * logoUrl;
@property (nonatomic, strong)NSString * cityStr;
@property (nonatomic, strong)NSString * modelStr;
@property (nonatomic, strong)NSNumber * carId;
@property (nonatomic, strong)NSNumber * cityId;

@end
