//
//  MutualInsStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"

#define kDomainMutualInsSimpleGroups    @"mutualIns.simpleGroups"
#define kDomainMutualInsDetailGroups    @"mutualIns.detailGroups"

@interface MutualInsStore : UserStore

@property (nonatomic, strong) JTQueue *simpleGroups;
@property (nonatomic, strong) JTQueue *detailGroups;

///最新的操作id
@property (nonatomic, strong)NSNumber * lastGroupId;

- (CKEvent *)reloadDetailGroupByMemberID:(NSNumber *)memberid andGroupID:(NSNumber *)groupid;
- (CKEvent *)reloadSimpleGroups;

@end
