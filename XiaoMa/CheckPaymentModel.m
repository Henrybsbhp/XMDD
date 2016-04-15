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
#import "PayForInsuranceVC.h"
#import "PayForGasViewController.h"
#import <NSObject+Notify.h>

@interface CheckPaymentModel()

@end


@implementation CheckPaymentModel

-(void)checkPaymentIsSuccess
{
    if ([gAppMgr.navModel.curNavCtrl.topViewController isKindOfClass:[PayForWashCarVC class]] || [gAppMgr.navModel.curNavCtrl.topViewController isKindOfClass:[PayForInsuranceVC class]] || [gAppMgr.navModel.curNavCtrl.topViewController isKindOfClass:[PayForGasViewController class]])
    {
        [self postCustomNotificationName:NSStringFromClass([gAppMgr.navModel.curNavCtrl.topViewController class]) object:nil];
    }
}


@end
