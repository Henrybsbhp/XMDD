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
                history.applyId = dic[@"applyid"];
                history.rescueStatus = [dic integerParamForName:@"rescuestatus"];
                history.commentStatus = [dic integerParamForName:@"commentstatus"];
                history.type = [dic integerParamForName:@"type"];
                
                if (history.type == HKRescueAnnual) {
                    history.appointTime = dic[@"appointtime"];
                }else {
                    history.appointTime = nil;
                }
                [rArray safetyAddObject:history];
            }
        }
        self.req_applysecueArray = rArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
        [gToast dismiss];
    }
    return self;
    

}
@end
