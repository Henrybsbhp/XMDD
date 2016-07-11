//
//  GetCooperationMyGroupOp.m
//  XiaoMa
//
//  Created by jt on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetCooperationMyGroupOp.h"
#import "HKMutualGroup.h"

@implementation GetCooperationMyGroupOp
;
- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/mygroup/get";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSArray * grouplist = rspObj[@"grouplist"];
    NSMutableArray * groupArray = [NSMutableArray array];
    for (NSDictionary * groupDict in grouplist)
    {
        HKMutualGroup * group = [[HKMutualGroup alloc] init];
        group.groupName = [groupDict stringParamForName:@"groupname"];
        group.btnStatus = [groupDict integerParamForName:@"status"];
        group.licenseNumber = [groupDict stringParamForName:@"licensenumber"];
        group.groupId = [groupDict numberParamForName:@"groupid"];
        group.tip = groupDict[@"tip"];
        group.leftTime = [groupDict numberParamForName:@"lefttime"];
        group.contractperiod = groupDict[@"contractperiod"];
        group.memberId = groupDict[@"memberid"];
        group.statusDesc  = [groupDict stringParamForName:@"statusdesc"];
        group.leftTimeTag = [[NSDate date] timeIntervalSince1970]; //数据初始化时记录时间戳
        [groupArray safetyAddObject:group];
    }
    self.rsp_groupArray = groupArray;
    
    NSArray * carList = rspObj[@"carlist"];
    NSMutableArray * carArray = [NSMutableArray array];
    for (NSDictionary * carDict in carList)
    {
        HKMutualCar * car = [[HKMutualCar alloc] init];
        car.brandLogo = [carDict stringParamForName:@"brandlogo"];
        car.licenseNum = [carDict stringParamForName:@"licensenum"];
        car.premiumPrice = [carDict stringParamForName:@"premiumprice"];
        car.couponMoney = [carDict stringParamForName:@"couponmoney"];
        car.carId = [carDict numberParamForName:@"carid"];
        
        [carArray safetyAddObject:car];
    }
    self.rsp_carArray = carArray;
    
    self.isShowPlanButton = [rspObj boolParamForName:@"showplanbtn"];
    
    self.isShowRegistButton = [rspObj boolParamForName:@"showregistbtn"];
    
    return self;
}


- (NSString *)description
{
    return @"获取用户本人已经参与过的团的状态信息（进入互助首页面调用）";
}

@end
