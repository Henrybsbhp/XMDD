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
        NSAssert(NO, @"AddUserFavoriteOp parse error~~");
    }
    return self;
    
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"收藏失败，请重试" code:error.code userInfo:error.userInfo];
    }
    return error;
}

- (NSString *)description
{
    return @"添加收藏";
}
@end
