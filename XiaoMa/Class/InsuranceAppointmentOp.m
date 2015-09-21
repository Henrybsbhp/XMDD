
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
    [params addParam:self.req_licencenumber forName:@"licencenumber"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:@(self.req_register) forName:@"register"];
    [params addParam:self.req_purchaseprice forName:@"purchaseprice"];
    if (self.req_purchasedate)
    {
        [params addParam:[self.req_purchasedate dateFormatForDT8] forName:@"purchasedate"];
    }
    [params addParam:self.req_phone forName:@"phone"];
    [params addParam:self.req_idcard forName:@"idcard"];
    [params addParam:self.req_idpic forName:@"idpic"];
    [params addParam:self.req_driverpic forName:@"driverpic"];
    [params addParam:self.req_inslist forName:@"inslist"];
    
      return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
