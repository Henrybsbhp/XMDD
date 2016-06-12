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
    self.simpleGroups = nil;
    self.unMutuanlCarList = nil;
    self.detailGroups = nil;
    [[self reloadSimpleGroups] send];
}

- (CKEvent *)reloadDetailGroupByMemberID:(NSNumber *)memberid andGroupID:(NSNumber *)groupid
{
    GetCooperationMygroupDetailOp *op = [GetCooperationMygroupDetailOp operation];
    op.req_groupid = groupid;
    op.req_memberid = memberid;
    op.req_version = gAppMgr.deviceInfo.appVersion;
    
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
        RACSignal *signal = [[[[GetCooperationMyGroupOp operation] rac_postRequest] doNext:^(GetCooperationMyGroupOp *op) {
            
            self.rsp_mygroupOp = op;
            
            JTQueue *groupList = [[JTQueue alloc] init];
            for (HKMutualGroup *group in op.rsp_groupArray) {
                [groupList addObject:group forKey:[group identify]];
            }
            self.simpleGroups = groupList;
            
            JTQueue *carList = [[JTQueue alloc] init];
            for (HKMutualCar *car in op.rsp_carArray) {
                [carList addObject:car forKey:[NSString stringWithFormat:@"%@", car.carId]];
            }
            self.unMutuanlCarList = carList;
        }] replayLast];
        event = [signal eventWithName:@"getSimpleGroups" object:nil];
    }
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
