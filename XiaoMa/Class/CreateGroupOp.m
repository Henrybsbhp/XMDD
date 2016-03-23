//
//  CreateGroupOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CreateGroupOp.h"

@implementation CreateGroupOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/group/add";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_name forName:@"name"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
