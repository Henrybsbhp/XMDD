//
//  GetNewbieInfoOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetNewbieInfoOp.h"

@implementation GetNewbieInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/carwash/info/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dic = rspObj;
    self.rsp_washcarflag = [dic[@"washcarflag"] integerValue];
    self.rsp_activitydayflag = [dic[@"activitydayflag"] integerValue];
    self.rsp_jumpwinflag = [dic[@"jumpwinflag"] integerValue];
    self.rsp_url = dic[@"url"];
    self.rsp_pic = dic[@"pic"];
    return self;
}

@end
