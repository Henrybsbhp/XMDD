#import "GetCooperationGroupMessageListOp.h"

@implementation GetCooperationGroupMessageListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/group/messagelist/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];
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

- (id)returnSimulateResponse {
    return @{@"rc": @0, @"lstupdatetime": @0, @"list":@[
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321},
  @{@"time": @"2016-07-12 16:26", @"licensenumber":@"浙A12345", @"content":@"天降阿锁单as大锁单阿索单阿达双杀大双as大搜集", @"memberid":@287},
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321},
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321},
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321},
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321},
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321},
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321},
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321},
  @{@"time": @"2016-06-21 12:23", @"licensenumber":@"浙A12345", @"content":@"[self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];", @"memberid":@321}]};
}

@end

