//
//  CommissionPaymentVC.h
//  XMDD
//
//  Created by St.Jimmy on 19/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GeneralTableViewVM.h"

@interface CommissionPaymentVM : GeneralTableViewVM

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC;

- (void)initialSetup;

@end
