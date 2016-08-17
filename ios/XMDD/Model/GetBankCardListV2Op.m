//
//  GetBankCardListV2Op.m
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetBankCardListV2Op.h"

@implementation GetBankCardListV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/bankcard/v2/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.isAll forName:@"isall"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in rspObj[@"cards"]) {
        MyBankCardListModel *coupon = [MyBankCardListModel listWithJSONResponse:dict];
        [array safetyAddObject:coupon];
    }
    
    self.cards = [NSArray arrayWithArray:array];
    
    return self;
}

@end
