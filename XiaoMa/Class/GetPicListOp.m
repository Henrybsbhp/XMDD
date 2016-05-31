//
//  GetPicListOp.m
//  XiaoMa
//
//  Created by RockyYe on 16/5/30.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetPicListOp.h"

@implementation GetPicListOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/claim/piclist/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_claimid forName:@"claimid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dic = rspObj;
    self.rsp_localelist = dic[@"localelist"];
    self.rsp_carlosslist = dic[@"carlosslist"];
    self.rsp_carinfolist = dic[@"carinfolist"];
    self.rsp_idphotolist = dic[@"carinfolist"];
    self.rsp_canaddflag = dic[@"canaddflag"];
    self.rsp_firstswitch = dic[@"firstswitch"];
    return self;
}

@end
