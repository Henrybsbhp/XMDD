//
//  InsuranceResultVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/7/29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    OrderSuccess = 0, //预约成功
    PaySuccess, //支付成功
    PayFailure //支付失败
} InsuranceResult;

@interface InsuranceResultVC : UIViewController

-(void) setResultType:(InsuranceResult) resultType;

@end
