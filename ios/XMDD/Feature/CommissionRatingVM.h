//
//  CommissionRatingVM.h
//  XMDD
//
//  Created by St.Jimmy on 20/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GeneralTableViewVM.h"
#import "GetRescueOrCommissionDetailOp.h"

@interface CommissionRatingVM : GeneralTableViewVM

@property (nonatomic, assign) NSInteger vcType;

@property (nonatomic, assign) NSInteger commentStatus;

@property (nonatomic, strong) GetRescueOrCommissionDetailOp *commissionDetailOp;

/// 记录 ID，请求数据的输入参数
@property (nonatomic, strong) NSNumber *applyID;

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC;

- (void)initialSetup;

@end
