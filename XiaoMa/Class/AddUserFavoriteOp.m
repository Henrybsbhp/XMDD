//
//  AddUserFavoriteOp.m
//  XiaoMa
//
//  Created by jt on 15-4-27.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AddUserFavoriteOp.h"

@implementation AddUserFavoriteOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/favorite/add";
    
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
        NSAssert(NO, @"GetUpdateInfoOp parse error~~");
    }
    return self;
    
}


@end
