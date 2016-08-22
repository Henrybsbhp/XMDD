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


@implementation MutualInsStore

- (void)reloadForUserChanged:(JTUser *)user
{
    self.carList = nil;
    self.detailGroups = nil;
    [[self reloadSimpleGroups] send];
}

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
    CKEvent *event;
    if (!gAppMgr.myUser) {
        event = [[RACSignal return:nil] eventWithName:@"reloadUser"];
    }
    else {
        RACSignal *signal = [[[[GetGroupJoinedInfoOp operation] rac_postRequest] doNext:^(GetGroupJoinedInfoOp *op) {
            
            self.rsp_getGroupJoinedInfoOp = op;
            self.carList = op.carList;
            self.couponDict = op.couponList;
            self.totalMemberCnt = op.totalMemberCnt;
            self.totalPoolAmt = op.totalPoolAmt;
            self.totalClaimCnt = op.totalClaimCnt;
            self.totalClaimAmt = op.totalClaimAmt;
        }] replayLast];
        event = [signal eventWithName:@"getSimpleGroups" object:nil];
    }
    return [self inlineEvent:event forDomain:kDomainMutualInsSimpleGroups];
}

- (CKEvent *)reloadOrderList
{
    CKEvent *event = [[RACSignal return:nil] eventWithName:@"reloadMutualInsOrderList"];
    return [self inlineEvent:event forDomain:kDomainMutualInsOrderList];
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
