//
//  GetShopRatesOp.m
//  XiaoMa
//
//  Created by jt on 15-4-15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetShopRatesOp.h"
#import "JTShop.h"

@implementation GetShopRatesOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/shop/rates/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.shopId forName:@"shopid"];
    [params addParam:self.pageno ? @(self.pageno):@(1) forName:@"pageno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * shops = (NSArray *)rspObj[@"rates"];
        NSMutableArray * tArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in shops)
        {
            JTShopComment * shop = [JTShopComment shopCommentWithJSONResponse:dict];
            [tArray addObject:shop];
        }
        self.rsp_shopCommentArray = tArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
