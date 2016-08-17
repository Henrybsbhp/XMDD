//
//  UPPayHelper.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UPPayHelper.h"
#import "UPayVerifyVC.h"

//接入模式  "00":代表生产环境   "01":代表测试环境、
#ifdef DEBUG
    #define UPPayPaymentMode  @"01"
#else
    #define UPPayPaymentMode  @"00"
#endif

@interface UPPayHelper ()
@end

@implementation UPPayHelper

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc
{
    UPayVerifyVC *vc = [UIStoryboard vcWithId:@"UPayVerifyVC" inStoryboard:@"Temp_YZC"];
    vc.customObject = [RACSubject subject];
    [tvc.navigationController pushViewController:vc animated:YES];
    return vc.customObject;
}

@end
