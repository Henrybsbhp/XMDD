//
//  CooperationGroupListVM.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CooperationGroupListVC.h"

typedef enum : NSInteger {
    GroupStatusTypeBegin = 1,
    GroupStatusTypeEnd = 2
} GroupStatusType;


@interface CooperationGroupListVM : NSObject

-(id)initWithTableView:(UITableView *)tableView andType:(GroupStatusType)groupStatusType andTargetVC:(CooperationGroupListVC *)groupListVC;

-(void)getCooperationGroupList;

@end
