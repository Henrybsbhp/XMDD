//
//  GetShareDetailOpV2.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/2.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetShareDetailOpV2.h"

@implementation GetShareDetailOpV2

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/share/detail/v2/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.pagePosition) forName:@"position"];
    [params addParam:@(self.buttonId) forName:@"buttonid"];
    [params addParam:@(self.gasCharge) forName:@"gascharge"];
    [params addParam:@(self.spareCharge) forName:@"sparecharge"];
    [params addParam:self.shareCode forName:@"sharecode"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

@end
