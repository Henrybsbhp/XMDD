//
//  MutualInsStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsStore.h"
#import "GetCooperationMygroupDetailOp.h"
#import "GetCooperationMyGroupOp.h"

@implementation MutualInsStore

- (CKEvent *)reloadDetailGroupIfNeededByMemberID:(NSNumber *)memberid
{
    GetCooperationMygroupDetailOp *op = [self.detailGroups objectForKey:memberid];
    if (op) {
        return [self reloadDetailGroupByMemberID:memberid andGroupID:op.req_groupid];
    }
    return nil;
}

- (CKEvent *)reloadDetailGroupByMemberID:(NSNumber *)memberid andGroupID:(NSNumber *)groupid
{
    GetCooperationMygroupDetailOp *op = [GetCooperationMygroupDetailOp operation];
    op.req_groupid = groupid;
    op.req_memberid = memberid;
    
    RACSignal *signal = [[[op rac_postRequest] doNext:^(GetCooperationMygroupDetailOp *op) {
        [[self detailGroups] addObject:op forKey:memberid];
    }] replayLast];
    
    CKEvent *event = [signal eventWithName:@"getDetailGroupByMemberID" object:op];
    return [self inlineEvent:event forDomain:kDomainMutualInsDetailGroups];
}

- (CKEvent *)getSimpleGroups
{
    RACSignal *signal = [[GetCooperationMyGroupOp operation] rac_postRequest];
    CKEvent *event = [signal eventWithName:@"getSimpleGroups" object:nil];
    return [self inlineEvent:event forDomain:kDomainMutualInsSimpleGroups];
}

#pragma mark - Getter
- (CKList *)detailGroups
{
    if (!_detailGroups) {
        _detailGroups = [CKList list];
    }
    return _detailGroups;
}

- (CKList *)simpleGroups
{
    if (!_simpleGroups) {
        _simpleGroups = [CKList list];
    }
    return _simpleGroups;
}

@end
