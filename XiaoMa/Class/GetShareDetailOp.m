//
//  GetShareDetailOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/26.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetShareDetailOp.h"

@implementation GetShareDetailOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/share/detail/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.pagePosition) forName:@"position"];
    [params addParam:@(self.buttonId) forName:@"buttonid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_title = [rspObj stringParamForName:@"title"];
        self.rsp_desc = [rspObj stringParamForName:@"desc"];
        self.rsp_linkurl = [rspObj stringParamForName:@"linkurl"];
        self.rsp_imgurl = [rspObj stringParamForName:@"imgurl"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
