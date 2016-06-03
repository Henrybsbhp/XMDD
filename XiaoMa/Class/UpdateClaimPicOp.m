//
//  UpdateClaimPicOp.m
//  XiaoMa
//
//  Created by RockyYe on 16/5/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UpdateClaimPicOp.h"

@implementation UpdateClaimPicOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/claim/pic/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_claimid forName:@"claimid"];
    
        [params addParam:self.req_localepic forName:@"localepic"];
        [params addParam:self.req_carlosspic forName:@"carlosspic"];
        [params addParam:self.req_carinfopic forName:@"carinfopic"];
        [params addParam:self.req_idphotopic forName:@"idphotopic"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}


@end
