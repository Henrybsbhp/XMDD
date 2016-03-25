//
//  MutualInsGrouponSubVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "MutualInsConstants.h"
#import "MutualInsGrouponVC.h"
#import "GetCooperationMygroupDetailOp.h"

@interface MutualInsGrouponSubVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) CGFloat expandedHeight;
@property (nonatomic, assign) CGFloat closedHeight;
@property (nonatomic, assign) BOOL shouldStopWaveView;
@property (nonatomic, copy) void(^shouldExpandedOrClosed)(BOOL expanded);

@property (nonatomic, strong) GetCooperationMygroupDetailOp *groupDetail;

@property (nonatomic, strong) HKMutualGroup *group;

- (void)reloadDataWithStatus:(MutInsStatus)status;

@end
