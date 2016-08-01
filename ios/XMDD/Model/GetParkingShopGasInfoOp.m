//
//  GetParkingShopGasInfoOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 6/29/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetParkingShopGasInfoOp.h"

@implementation GetParkingShopGasInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/extshop/search";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.searchType forName:@"searchtype"];
    [params addParam:self.longitude forName:@"longitude"];
    [params addParam:self.latitude forName:@"latitude"];
    [params addParam:self.pageNo forName:@"pageno"];
    [params addParam:self.range forName:@"range"];
    [params addParam:self.cityCode forName:@"citycode"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.extShops = rspObj[@"extshops"];
    
    return self;
}

- (NSString *)description
{
    return @"获取附近停车，4S店，加油站等信息";
}

@end
