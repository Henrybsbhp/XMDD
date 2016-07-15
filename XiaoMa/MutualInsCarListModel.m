//
//  MutualInsCarListModel.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/14/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsCarListModel.h"

@implementation MutualInsCarListModel

+ (instancetype)carlistWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return nil;
    }
    
    MutualInsCarListModel *carListModel = [[MutualInsCarListModel alloc] init];
    carListModel.brandLogo = rsp[@"brandlogo"];
    carListModel.licenseNum = rsp[@"licensenum"];
    carListModel.tip = rsp[@"tip"];
    carListModel.status = [rsp[@"status"] integerValue];
    carListModel.statusDesc = rsp[@"statusdesc"];
    carListModel.couponList = rsp[@"couponlist"];
    carListModel.numberCnt = rsp[@"numbercnt"];
    carListModel.contractID = rsp[@"contractid"];
    carListModel.extendInfo = rsp[@"extendinfo"];
    carListModel.groupName = rsp[@"groupname"];
    carListModel.groupID = rsp[@"groupid"];
    carListModel.memberID = rsp[@"memberid"];
    carListModel.userCarID = rsp[@"usercarid"];
    
    return carListModel;
}

@end
