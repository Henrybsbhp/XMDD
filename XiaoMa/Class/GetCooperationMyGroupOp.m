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

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/mygroup/get";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSArray * grouplist = rspObj[@"grouplist"];
    NSMutableArray * array = [NSMutableArray array];
    for (NSDictionary * groupDict in grouplist)
    {
        HKMutualGroup * group = [[HKMutualGroup alloc] init];
        group.groupName = [groupDict stringParamForName:@"groupname"];
        group.btnStatus = [groupDict integerParamForName:@"status"];
        group.licenseNumber = [groupDict stringParamForName:@"licensenumber"];
        group.groupId = [groupDict numberParamForName:@"groupid"];
        group.tip = groupDict[@"tip"];
        group.lefetime = [groupDict numberParamForName:@"lefetime"];
        group.contractperiod = groupDict[@"tip"];
        group.memberId = [groupDict stringParamForName:@"memberid"];
        group.statusDesc  = [groupDict stringParamForName:@"statusdesc"];
    }
    self.rsp_groupArray = array;
    return self;
}

@end
