//
//  MutualOrderListGetOp.m
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualOrderListGetOp.h"
#import "MutualOrderListModel.h"

@implementation MutualOrderListGetOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/cooperation/orderhis/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *orderArray = [NSMutableArray array];
    for (NSDictionary *orderDict in dict[@"cooperationdatas"]) {
        MutualOrderListModel *order = [MutualOrderListModel orderWithJSONResponse:orderDict];
        [orderArray safetyAddObject:order];
    }
    
    self.cooperationData = orderArray;
    
    return self;
}

@end
