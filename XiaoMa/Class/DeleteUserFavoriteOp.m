//
//  DeleteUserFavoriteOp.m
//  XiaoMa
//
//  Created by jt on 15-5-4.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DeleteUserFavoriteOp.h"

@implementation DeleteUserFavoriteOp

-(RACSignal *)rac_postRequest
{
    self.req_method = @"/user/favorite/delete";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.shopid forName:@"shopid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if([rspObj isKindOfClass:[NSDictionary class]])
    {
        //        NSDictionary * dict = (NSDictionary *)rspObj;
    }
    else
    {
        NSAssert(NO, @"DeleteUserFavoriteOp parse error~~");
    }
    return self;
}

@end
