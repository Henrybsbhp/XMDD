//
//  MutualInsGroupDetailChildVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MutualInsGroupDetailVM;

@interface MutualInsGroupDetailChildVC : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CKList *datasource;

- (MutualInsGroupDetailVM *)viewModel;
///@Override
- (CKList *)createDatasource;

@end
