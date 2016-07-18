//
//  MutualInsDetailVM.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupDetailVM.h"

#define kSimulateResponse  NO
NSInteger const kFetchPageAmount = 10;

@implementation MutualInsGroupDetailVM
- (void)dealloc {
    
}

+ (instancetype)fetchForGroupID:(NSNumber *)groupID memberID:(NSNumber *)memberID {
    MutualInsGroupDetailVM *vm = [self fetchExistsStoreForKey:[self keyWithGroupID:groupID andMemberID:memberID]];
    vm.groupID = groupID;
    vm.memberID = memberID;
    return vm;
}
+ (instancetype)fetchOrCreateForGroupID:(NSNumber *)groupID memberID:(NSNumber *)memberID {
    MutualInsGroupDetailVM *vm = [self fetchOrCreateStoreForKey:[self keyWithGroupID:groupID andMemberID:memberID]];
    vm.groupID = groupID;
    vm.memberID = memberID;
    return vm;
}

+ (NSString *)keyWithGroupID:(NSNumber *)groupID andMemberID:(NSNumber *)memberID {
    return [NSString stringWithFormat:@"MutualIns.Group.Detail.ViewModel.%@.%@", groupID, memberID];
}

- (void)fetchBaseInfoForce:(BOOL)force {
    if (!force && self.reloadBaseInfoSignal) {
        return;
    }
    
    GetCooperationGroupConfigOp *op = [GetCooperationGroupConfigOp operation];
    op.req_groupid = self.groupID;
    op.req_memberid = self.memberID;

    @weakify(self);
    self.reloadBaseInfoSignal = [[op rac_postRequest] doNext:^(id x) {
        
        @strongify(self);
        self.baseInfo = x;
    }];
}

- (void)fetchMyInfoForce:(BOOL)force {
    if (!force && self.reloadMyInfoSignal) {
        return;
    }

    GetCooperationGroupMyInfoOp *op = [GetCooperationGroupMyInfoOp operation];
    op.req_groupid = self.groupID;
    op.req_memberid = self.memberID;
    op.simulateResponse = kSimulateResponse;
    op.simulateResponseDelay = 1;
    @weakify(self);
    self.reloadMyInfoSignal = [[op rac_postRequest] doNext:^(id x) {
        
        @strongify(self);
        self.myInfo = x;
    }];
}

- (void)fetchFundInfoForce:(BOOL)force {
    if (!force && self.reloadFundInfoSignal) {
        return;
    }
    GetCooperationGroupSharemoneyOp *op = [GetCooperationGroupSharemoneyOp operation];
    op.req_groupid = self.groupID;
    op.simulateResponse = kSimulateResponse;
    op.simulateResponseDelay = 1;
    
    @weakify(self);
    self.reloadFundInfoSignal = [[op rac_postRequest] doNext:^(id x) {

        @strongify(self);
        self.fundInfo = x;
    }];
}

- (void)fetchMembersInfoForce:(BOOL)force {
    if (!force && self.reloadMembersInfoSignal) {
        return;
    }
    GetCooperationGroupMembersOp *op = [GetCooperationGroupMembersOp operation];
    op.req_groupid = self.groupID;
    op.req_lstupdatetime = self.membersInfo ? self.membersInfo.rsp_lstupdatetime : 0;
    op.simulateResponse = kSimulateResponse;
    op.simulateResponseDelay = 1;
    
    @weakify(self);
    self.reloadMembersInfoSignal = [[op rac_postRequest] doNext:^(id x) {

        @strongify(self);
        self.membersInfo = x;
    }];
}

- (void)fetchMessagesInfoForce:(BOOL)force {
    if (!force && self.reloadMessagesInfoSignal) {
        return;
    }
    GetCooperationGroupMessageListOp *op = [GetCooperationGroupMessageListOp operation];
    op.req_groupid = self.groupID;
    op.req_lstupdatetime = 0;
    op.simulateResponse = kSimulateResponse;
    op.simulateResponseDelay = 1;
    
    @weakify(self);
    self.reloadMessagesInfoSignal = [[op rac_postRequest] doNext:^(id x) {
        
        @strongify(self);
        self.messagesInfo = x;
    }];
}

- (void)fetchMoreMessagesInfo {
    
    GetCooperationGroupMessageListOp *op = [GetCooperationGroupMessageListOp operation];
    op.req_groupid = self.groupID;
    op.req_lstupdatetime = self.messagesInfo.rsp_lstupdatetime;
    op.simulateResponse = kSimulateResponse;
    op.simulateResponseDelay = 1;
    
    @weakify(self);
    self.loadMoreMessagesInfoSignal = [[[op rac_postRequest] doNext:^(id x) {
        
        @strongify(self);
        self.messagesInfo = x;
    }] finally:^{
        
        @strongify(self);
        self.loadMoreMessagesInfoSignal = nil;
    }];
}

- (void)fetchMoreMembersInfo {
    GetCooperationGroupMembersOp *op = [GetCooperationGroupMembersOp operation];
    op.req_groupid = self.groupID;
    op.req_lstupdatetime = self.membersInfo.rsp_lstupdatetime;
    op.simulateResponse  = kSimulateResponse;
    op.simulateResponseDelay = 1;
    
    @weakify(self);
    self.loadMoreMembersInfoSignal = [[[op rac_postRequest] doNext:^(id x) {
        
        @strongify(self);
        self.membersInfo = x;
    }] finally:^{
        
        @strongify(self);
        self.loadMoreMembersInfoSignal = nil;
    }];
}

- (BOOL)saveTimetagIfNeeded:(long long)timetag forKey:(NSString *)key {
    NSString *fullkey = [NSString stringWithFormat:@"$MutualIns.Group.Detail.%@.%@.Timetag.%@",
                         self.groupID, self.memberID, key];
    long long oldTimetag = [[[NSUserDefaults standardUserDefaults] objectForKey:fullkey] longLongValue];
    if (oldTimetag < timetag) {
        [[NSUserDefaults standardUserDefaults] setObject:@(timetag) forKey:fullkey];
        return YES;
    }
    return NO;
}

@end
