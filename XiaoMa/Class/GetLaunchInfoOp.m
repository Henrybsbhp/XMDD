//
//  getLaunchInfoOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetLaunchInfoOp.h"

#define kLaunchInfoStoreKey   @"$LaunchInfoKey"

@implementation GetLaunchInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/appstart/adpic";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_district forName:@"district"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:rspObj];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [dict safetySetObject:self.req_province forKey:@"province"];
    [dict safetySetObject:self.req_city forKey:@"city"];
    [dict safetySetObject:self.req_district forKey:@"district"];
    [def setObject:dict forKey:kLaunchInfoStoreKey];
    self.rsp_infoList = [GetLaunchInfoOp parseLuanchInfosWithDict:dict];
    
    return self;
}

+ (HKAddressComponent *)parseAddressWithDict:(NSDictionary *)dict
{
    HKAddressComponent *addr = [[HKAddressComponent alloc] init];
    addr.province = dict[@"province"];
    addr.city = dict[@"city"];
    addr.district = dict[@"district"];
    return addr;
}

+ (NSArray *)parseLuanchInfosWithDict:(NSDictionary *)dict
{
    NSArray *array = dict[@"adverts"];
    NSMutableArray *infoList = [NSMutableArray array];
    for (NSDictionary *item in array) {
        HKLaunchInfo *info = [HKLaunchInfo launchInfoWithJSONResponse:item];
        [infoList addObject:info];
    }
    return infoList;
}

+ (NSDictionary *)fetchSavedLaunchInfosDict
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLaunchInfoStoreKey];
}

- (NSString *)description
{
    return @"获取启动页";
}
@end
