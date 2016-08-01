//
//  MutualInsGroupDetailChildVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutualInsGroupDetailVM.h"

@interface MutualInsGroupDetailChildVC : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong, readonly) MutualInsGroupDetailVM *viewModel;

@end
