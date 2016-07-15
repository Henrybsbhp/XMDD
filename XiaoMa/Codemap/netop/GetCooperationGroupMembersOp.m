#import "GetCooperationGroupMembersOp.h"

@implementation GetCooperationGroupMembersOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/groupmember/list/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];
    [params safetySetObject:@(self.req_lstupdatetime) forKey:@"lstupdatetime"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_membercnt = [dict[@"membercnt"] intValue];
    NSMutableArray *memberlist = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"memberlist"]) {
        MutualInsMemberInfo2 *obj = [MutualInsMemberInfo2 createWithJSONDict:curDict];
        [memberlist addObject:obj];
    }
    self.rsp_memberlist = memberlist;
    self.rsp_lstupdatetime = [dict[@"lstupdatetime"] longLongValue];
    self.rsp_toptip = dict[@"toptip"];
	
    return self;
}

- (id)returnSimulateResponse {
    return @{@"rc": @0,
             @"lstupdatetime": @0, @"toptip": @"互助中", @"isHelping": @1, @"membercnt": @100,
             @"memberlist":@[
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
                     @{@"status": @10, @"statusdesc": @"保障结束", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"1次"}, @{@"加入时间": @"123120390123dasdoashasoswodajdasdjasodjsdoasdasodjads"}]},
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
                     @{@"status": @8, @"statusdesc": @"互助中", @"licensenumber":@"浙A12345", @"extendinfo":@[@{@"品牌车系": @"宝马X6"}, @{@"补偿次数": @"0次"}]},
             ]};
}

@end

