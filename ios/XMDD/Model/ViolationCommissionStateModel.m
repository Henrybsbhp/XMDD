//
//  ViolationCommissionStateModel.m
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "ViolationCommissionStateModel.h"

@implementation ViolationCommissionStateModel

+ (instancetype)listWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return nil;
    }
    
    ViolationCommissionStateModel *list = [ViolationCommissionStateModel new];
    list.licenceNumber = rsp[@"licencenumber"];
    list.area = rsp[@"area"];
    list.act = rsp[@"act"];
    list.status = [rsp[@"status"] integerValue];
    list.tips = rsp[@"tip"];
    list.orderInfo = rsp[@"orderinfo"];
    list.finishPicURL = rsp[@"finishpicurl"];
    
    return list;
}

@end
