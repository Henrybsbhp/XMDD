//
//  MutualInsStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "GetGroupJoinedInfoOp.h"

#define kDomainMutualInsSimpleGroups    @"mutualIns.simpleGroups"
#define kDomainMutualInsDetailGroups    @"mutualIns.detailGroups"

@interface MutualInsStore : UserStore

@property (nonatomic, strong) NSArray *carList;
@property (nonatomic, strong) GetGroupJoinedInfoOp *rsp_getGroupJoinedInfoOp;
@property (nonatomic, strong) JTQueue *detailGroups;


- (CKEvent *)reloadDetailGroupByMemberID:(NSNumber *)memberid andGroupID:(NSNumber *)groupid;
- (CKEvent *)reloadSimpleGroups;

@end
