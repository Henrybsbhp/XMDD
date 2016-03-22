//
//  MutualInsStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsStore.h"
#import "HKMutualGroup.h"
#import "GetCooperationMygroupDetailOp.h"
#import "GetCooperationMyGroupOp.h"

@implementation MutualInsStore

- (CKEvent *)reloadDetailGroupByMemberID:(NSNumber *)memberid andGroupID:(NSNumber *)groupid
{
    GetCooperationMygroupDetailOp *op = [GetCooperationMygroupDetailOp operation];
    op.req_groupid = groupid;
    op.req_memberid = memberid;
    
    RACSignal *signal = [[[op rac_postRequest] doNext:^(GetCooperationMygroupDetailOp *op) {
        [[self getOrCreateDetailGroups] addObject:op forKey:groupid];
    }] replayLast];
    
    CKEvent *event = [signal eventWithName:@"getDetailGroupByMemberID" object:op];
    return [self inlineEvent:event forDomain:kDomainMutualInsDetailGroups];
}

- (CKEvent *)reloadSimpleGroups
{
    RACSignal *signal = [[[[GetCooperationMyGroupOp operation] rac_postRequest] doNext:^(GetCooperationMyGroupOp *op) {
        JTQueue *groupList = [[JTQueue alloc] init];
        for (HKMutualGroup *group in op.rsp_groupArray) {
            [groupList addObject:group forKey:group.groupId];
        }
        self.simpleGroups = groupList;
    }] replayLast];
    CKEvent *event = [signal eventWithName:@"getSimpleGroups" object:nil];
    return [self inlineEvent:event forDomain:kDomainMutualInsSimpleGroups];
}

#pragma mark - Getter
- (JTQueue *)getOrCreateDetailGroups
{
    if (!_detailGroups) {
        _detailGroups = [[JTQueue alloc] init];
    }
    return _detailGroups;
}
@end
