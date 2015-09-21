
//
//  InsuranceAppointmentOp.m
//  XiaoMa
//  本代码由ckools工具自动生成,工具详情请联系作者@江俊辰
//  Created by Ckools
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceAppointmentOp.h"

@implementation InsuranceAppointmentOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/appointment";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_licencenumber forKey:@"licencenumber"];
    [params safetySetObject:self.req_city forKey:@"city"];
    [params safetySetObject:@(self.req_register) forKey:@"register"];
    [params safetySetObject:self.req_purchaseprice forKey:@"purchaseprice"];
    if (self.req_purchasedate) {
        [params safetySetObject:[self.req_purchasedate dateFormatForDT8] forKey:@"purchasedate"];
    }
    [params safetySetObject:self.req_phone forKey:@"phone"];
    [params safetySetObject:self.req_idcard forKey:@"idcard"];
    [params safetySetObject:self.req_idpic forKey:@"idpic"];
    [params safetySetObject:self.req_driverpic forKey:@"driverpic"];
    [params safetySetObject:self.req_inslist forKey:@"inslist"];
    
      return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
