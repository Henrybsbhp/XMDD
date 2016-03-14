//
//  HKTableViewController.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "CKDatasource.h"

@interface HKTableViewController : HKViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) CKList *datasource;
@end
