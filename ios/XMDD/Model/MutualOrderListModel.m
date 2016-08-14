//
//  MutualOrderListModel.m
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualOrderListModel.h"

@implementation MutualOrderListModel

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return nil;
    }
    
    MutualOrderListModel *order = [MutualOrderListModel new];
    order.contractid = rsp[@"contractid"];
    order.licenseNumber = rsp[@"licensenumber"];
    order.brandLogoAddress = rsp[@"brandlogo"];
    order.createTime = rsp[@"createtime"];
    order.insStartTime = rsp[@"insstarttime"];
    order.insEndTime = rsp[@"insendtime"];
    order.sharedMoney = rsp[@"sharemoney"];
    order.memberFee = rsp[@"memberfee"];
    order.fee = rsp[@"fee"];
    order.status = [rsp[@"status"] integerValue];
    order.statusDesc = rsp[@"statusdesc"];
    order.forceInfo = [InsuranceOrderListModel orderWithDict:rsp[@"forceinfo"]];
    
    return order;
}

@end


@implementation InsuranceOrderListModel

+ (instancetype)orderWithDict:(NSDictionary *)dict
{
    if (!dict) {
        return nil;
    }
    
    InsuranceOrderListModel *order = [InsuranceOrderListModel new];
    order.forceFee = dict[@"forcefee"];
    order.taxShipFee = dict[@"taxshipfee"];
    order.insComp = dict[@"inscomp"];
    order.forceStartDate = dict[@"forcestartdate"];
    order.forceEndDate = dict[@"forceenddate"];
    order.proxyLogo = dict[@"proxylogo"];
    order.createTime = dict[@"createtime"];
    return order;
}

@end
