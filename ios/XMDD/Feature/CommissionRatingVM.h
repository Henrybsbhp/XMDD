//
//  CommissionRatingVM.h
//  XMDD
//
//  Created by St.Jimmy on 20/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GeneralTableViewVM.h"

@interface CommissionRatingVM : GeneralTableViewVM

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC;

- (void)initialSetup;

@end
