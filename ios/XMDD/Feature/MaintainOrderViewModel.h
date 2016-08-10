//
//  MaintainOrderViewModel.h
//  XMDD
//
//  Created by St.Jimmy on 8/4/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTTableView.h"
#import "HKLoadingModel.h"

@interface MaintainOrderViewModel : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) JTTableView *tableView;
@property (nonatomic, weak, readonly) UIViewController *targetVC;
@property (nonatomic, strong) HKLoadingModel *loadingModel;

- (id)initWithTableView:(JTTableView *)tableView;
- (void)resetWithTargetVC:(UIViewController *)targetVC;

@end
