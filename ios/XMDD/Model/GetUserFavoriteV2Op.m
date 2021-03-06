//
//  GetUserFavoriteV2Op.m
//  XiaoMa
//
//  Created by jt on 15/10/19.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserFavoriteV2Op.h"
#import "JTShop.h"

@implementation GetUserFavoriteV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/favorite/v2/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.pageno) forName:@"pageno"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
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

- (NSString *)description
{
    return @"查看收藏的商家";
}
@end
