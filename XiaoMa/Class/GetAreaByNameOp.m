//
//  GetAreaByNameOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "GetAreaByNameOp.h"
#import "Area.h"

@implementation GetAreaByNameOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/province/getarea/bypcd";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_district forName:@"district"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_province = [Area createWithJSONDict:dict[@"province"]];
    self.rsp_province.level = AreaLevelProvince;
    self.rsp_city = [Area createWithJSONDict:dict[@"city"]];
    self.rsp_city.level = AreaLevelCity;
    self.rsp_district = [Area createWithJSONDict:dict[@"district"]];
    self.rsp_district.level = AreaLevelDistrict;

    return self;
}

@end
