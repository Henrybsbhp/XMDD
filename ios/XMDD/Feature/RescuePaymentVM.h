//
//  RescuePaymentVM.h
//  XMDD
//
//  Created by St.Jimmy on 18/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GeneralTableViewVM.h"
#import "GetRescueOrCommissionDetailOp.h"

@interface RescuePaymentVM : GeneralTableViewVM

@property (nonatomic, assign) NSInteger vcType;

@property (nonatomic, strong) GetRescueOrCommissionDetailOp *rescueDetialOp;

/// 记录 ID，请求数据的输入参数
@property (nonatomic, strong) NSNumber *applyID;

@property (nonatomic, strong) UIButton *confirmButton;

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC;

- (void)initialSetup;

@end
