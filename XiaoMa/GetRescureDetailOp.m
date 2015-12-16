//
//  GetRescureDetailOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescureDetailOp.h"
#import "HKRescureDetail.h"
@implementation GetRescureDetailOp
- (RACSignal *)rac_postRequest {
    self.req_method = @"/rescue/get/rescuedetail";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.rescueid) forName:@"rescueid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
    
}
- (instancetype)parseResponseObject:(id)rspObj
{
    
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rescueDetailArray = [@[] mutableCopy];
        NSDictionary *dic = rspObj[@"rescuedetail"];
        NSLog(@"%lu", dic.count);
        if (dic != nil) {
            HKRescureDetail *detail  = [[HKRescureDetail alloc] init];
            detail.rescueid = dic[@"serviceobject"];
            detail.feesacle = dic[@"feesacle"];
            detail.serviceobject = dic[@"serviceproject"];
            detail.rescueid = dic[@"rescueid"];
            [self.rescueDetailArray safetyAddObject:dic[@"serviceobject"]];
            [self.rescueDetailArray safetyAddObject:dic[@"feesacle"]];
            [self.rescueDetailArray safetyAddObject:dic[@"serviceproject"]];

        }
    }
    
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
    
}
@end
