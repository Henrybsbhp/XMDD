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
    self.rsp_linkUrl = [rspObj stringParamForName:@"linkurl"];
    self.rsp_content = [rspObj stringParamForName:@"content"];
    self.rsp_title = [rspObj stringParamForName:@"title"];
    self.rsp_wechatUrl = [rspObj stringParamForName:@"wechat_picurl"];
    self.rsp_weiboUrl = [rspObj stringParamForName:@"pic_url"];
    
    return self;
}

@end
