//
//  MutualInsStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "CKDatasource.h"

#define kDomainMutualInsSimpleGroups    @"mutualIns.simpleGroups"
#define kDomainMutualInsDetailGroups    @"mutualIns.detailGroups"

@interface MutualInsStore : UserStore

@property (nonatomic, strong) CKList *simpleGroups;
@property (nonatomic, strong) CKList *detailGroups;

- (CKEvent *)reloadDetailGroupByMemberID:(NSNumber *)memberid andGroupID:(NSNumber *)groupid;
- (CKEvent *)reloadSimpleGroups;
- (CKEvent *)reloadDetailGroupIfNeededByMemberID:(NSNumber *)memberid;

@end
