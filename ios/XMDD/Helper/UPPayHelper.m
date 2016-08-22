//
//  UPPayHelper.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UPPayHelper.h"
#import "AddBankCardVC.h"
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

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn bankCardInfo:(NSArray *)bankCardInfo unionPayDesc:(NSString *)unionPayDesc totalFee:(CGFloat)total targetVC:(UIViewController *)tvc
{
    if (bankCardInfo.count == 0)
    {
        RACSubject *subject = [RACSubject subject];
        
        AddBankCardVC *vc = [UIStoryboard vcWithId:@"AddBankCardVC" inStoryboard:@"HX_Temp"];
        vc.tradeNum = tn;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        [tvc presentViewController:navi animated:YES completion:nil];
        [vc.subject subscribeNext:^(NSString *url) {
            
            if ([url isEqualToString:@""])
            {
                [subject sendNext:url];
            }
            
        }];
        
        return subject;
    }
    else
    {
        UPayVerifyVC *vc = [UIStoryboard vcWithId:@"UPayVerifyVC" inStoryboard:@"Temp_YZC"];
        vc.bankCardInfo = bankCardInfo;
        vc.orderFee = total;
        vc.serviceName = unionPayDesc;
        vc.tradeNo = tn;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        [tvc presentViewController:navi animated:YES completion:nil];
        
        return vc.subject;
    }
    
}

@end
