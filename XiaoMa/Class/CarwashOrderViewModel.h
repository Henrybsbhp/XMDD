//
//  CarwashOrderViewModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTTableView.h"

@interface CarwashOrderViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) NSMutableArray *orders;
@property (nonatomic, weak, readonly) UIViewController *targetVC;
- (void)reloadData;
- (void)resetWithTargetVC:(UIViewController *)targetVC;

@end
