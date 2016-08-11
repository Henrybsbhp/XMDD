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
#define kDomainMutualInsOrderList    @"mutualIns.orderList"

@interface MutualInsStore : UserStore

/// 车辆信息
@property (nonatomic, strong) NSArray *carList;
/// 优惠信息
@property (nonatomic, strong) NSDictionary *couponDict;
@property (nonatomic, strong) GetGroupJoinedInfoOp *rsp_getGroupJoinedInfoOp;
@property (nonatomic, strong) JTQueue *detailGroups;


- (CKEvent *)reloadDetailGroupByMemberID:(NSNumber *)memberid andGroupID:(NSNumber *)groupid;
- (CKEvent *)reloadSimpleGroups;
- (CKEvent *)reloadOrderList;

@end
