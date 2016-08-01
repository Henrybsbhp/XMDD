//
//  GetAutomobileBrandV2Op.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "GetAutomobileBrandV2Op.h"

@implementation GetAutomobileBrandV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/brand/v2/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_timetag forName:@"timetag"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_brands = dict[@"brands"];
    
    return self;
}

- (NSString *)description
{
    return @"获取车型信息";
}

@end
