//
//  GetRescueHistoryOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescueHistoryOp.h"
#import "HKRescueHistory.h"
@implementation GetRescueHistoryOp
- (RACSignal *)rac_postRequest {
   self.req_method = @"/rescue/history";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.applytime) forName:@"applytime"];
    [params addParam:@(self.type) forName:@"type"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj {
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        
        NSMutableArray * rArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in rspObj[@"rescuelist"]) {
            if (dic != nil) {
                HKRescueHistory *history = [[HKRescueHistory alloc] init];
                history.applyTime = dic[@"applytime"];
                history.serviceName = dic[@"servicename"];
                history.licenceNumber = dic[@"licencenumber"];
                history.rescueStatus = [dic integerParamForName:@"rescuestatus"];
                history.commentStatus = [dic integerParamForName:@"commentstatus"];
                history.applyId = dic[@"applyid"];
                history.type = [dic integerParamForName:@"type"];
                history.appointTime = dic[@"appointtime"];
                history.pay = dic[@"pay"];
                [rArray safetyAddObject:history];
            }
        }
        self.rsp_applysecueArray = rArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
        [gToast dismiss];
    }
    return self;
}


- (NSString *)description
{
    return @"获取救援历史";
}
@end
