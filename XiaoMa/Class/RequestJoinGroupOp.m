//
//  RequestJoinGroupOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/18/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "RequestJoinGroupOp.h"

@implementation RequestJoinGroupOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/group/search";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.cipher forName:@"cipher"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.groupDict = dict;
    
    return self;
}

@end
