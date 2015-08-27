//
//  GetBankcardListOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetBankcardListOp.h"

@implementation GetBankcardListOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/bankcard/get";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSArray *cardlist = dict[@"bankcardlist"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *cardInfo in cardlist) {
        HKBankCard *card = [HKBankCard bankCardWithJSONResponse:cardInfo];
        [array addObject:card];
    }
    self.rsp_bankcards = array;
    
    return self;
}


@end
