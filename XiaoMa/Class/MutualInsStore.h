//
//  MutualInsStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "GetCooperationMyGroupOp.h"

#define kDomainMutualInsSimpleGroups    @"mutualIns.simpleGroups"
#define kDomainMutualInsDetailGroups    @"mutualIns.detailGroups"

@interface MutualInsStore : UserStore

@property (nonatomic, strong) JTQueue *simpleGroups;
@property (nonatomic, strong) JTQueue *unMutuanlCarList;
@property (nonatomic, strong) GetCooperationMyGroupOp *rsp_mygroupOp;
@property (nonatomic, strong) JTQueue *detailGroups;


- (CKEvent *)reloadDetailGroupByMemberID:(NSNumber *)memberid andGroupID:(NSNumber *)groupid;
- (CKEvent *)reloadSimpleGroups;

@end
