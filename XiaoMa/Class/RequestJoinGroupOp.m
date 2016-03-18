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
    [params addParam:self.cipher forName:@"name"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSString *groupName = dict[@"name"];
    NSString *groupLeaderNM = dict[@"creatorname"];
    NSString *groupID = dict[@"groupid"];
    
    self.groupDict = @{@"name" : groupName,
                @"creatorname" : groupLeaderNM,
                    @"groupid" : groupID
                       };
    
    return self;
}

@end
