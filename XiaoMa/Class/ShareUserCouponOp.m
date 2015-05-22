//
//  ShareUserCouponOp.m
//  XiaoMa
//
//  Created by jt on 15-5-22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ShareUserCouponOp.h"

@implementation ShareUserCouponOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/coupon/share";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.cid forName:@"cid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (id)parseResponseObject:(id)rspObj
{
    self.rsp_linkUrl = rspObj[@"linkurl"];
    self.rsp_picUrl = rspObj[@"pic_url"];
    self.rsp_content = rspObj[@"content"];
    self.rsp_title = rspObj[@"title"];
    
    return self;
}

@end
