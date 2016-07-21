#import "GetCooperationGroupMessageListOp.h"

@implementation GetCooperationGroupMessageListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/group/messagelist/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];
    [params safetySetObject:@(self.req_lstupdatetime) forKey:@"lstupdatetime"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"list"]) {
        MutualInsMessage *obj = [MutualInsMessage createWithJSONDict:curDict];
        [list addObject:obj];
    }
    self.rsp_list = list;
    self.rsp_lstupdatetime = [dict[@"lstupdatetime"] longLongValue];
	
    return self;
}

@end

