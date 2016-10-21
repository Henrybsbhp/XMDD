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

@property (nonatomic, strong) GetRescueOrCommissionDetailOp *rescueDetialOp;

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC;

- (void)initialSetup;

@end
