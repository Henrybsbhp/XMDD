//
//  GetShopByDistanceOp.m
//  XiaoMa
//
//  Created by jt on 15-4-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetShopByDistanceOp.h"
#import "JTShop.h"

@implementation GetShopByDistanceOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/shop/get/by-distance";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.longitude) forName:@"longitude"];
    [params addParam:@(self.latitude) forName:@"latitude"];
    [params addParam:self.pageno ? @(self.pageno):@(1) forName:@"pageno"];
    //    [params addParam:@(self.typemask) forName:@"typemask"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * shops = (NSArray *)rspObj[@"shops"];
        NSMutableArray * tArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in shops)
        {
            JTShop * shop = [JTShop shopWithJSONResponse:dict];
            [tArray addObject:shop];
        }
        self.rsp_shopArray = tArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
