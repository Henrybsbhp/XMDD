//
//  CheckPaymentModel.m
//  XiaoMa
//
//  Created by RockyYe on 16/4/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CheckPaymentModel.h"
#import "PayForWashCarVC.h"
#import "PaymentSuccessVC.h"
#import "GetPayStatusOp.h"
#import <NSObject+Notify.h>

@interface CheckPaymentModel()

@end


@implementation CheckPaymentModel

-(void)checkPaymentIsSuccess
{
    if ([gAppMgr.navModel.curNavCtrl.topViewController isKindOfClass:[PayForWashCarVC class]])
    {
        [self postCustomNotificationName:NSStringFromClass([gAppMgr.navModel.curNavCtrl.topViewController class]) object:nil];
    }
}

-(void)getPayStatusWithTradeno:(NSString *)tradeno andTradetype:(NSString *)tradetype andVC:(UIViewController *)vc
{
    @weakify(self)
    
    
    
}


@end
